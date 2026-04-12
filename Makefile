SHELL := /bin/bash

PYTHON ?= $(shell if [ -x ./.venv/bin/python ]; then echo ./.venv/bin/python; else echo python3; fi)
PIP ?= $(PYTHON) -m pip
COMPOSE ?= docker compose
OBS_COMPOSE ?= docker compose -f docker-compose.yml -f infra/observability/docker-compose.observability.yml
EC2_HOST ?=
REPO ?= Devydv/Smart-Hoste
REF ?=

.DEFAULT_GOAL := help

.PHONY: help setup up down status logs lint test ci-check clean health k8s-validate deploy-manual ci-cd-show parity-check monitor-up monitor-down monitor-status rollback

help:
	@echo "Available targets:"
	@echo "  make setup          - Create .venv and install Python dependencies"
	@echo "  make up             - Start local stack"
	@echo "  make down           - Stop local stack"
	@echo "  make status         - Show local stack status"
	@echo "  make logs           - Tail container logs"
	@echo "  make lint           - Run Ruff"
	@echo "  make test           - Run Pytest"
	@echo "  make ci-check       - Lint + test + compose config + docker build"
	@echo "  make parity-check   - Validate local/CI/deploy environment parity"
	@echo "  make monitor-up     - Start Prometheus, Grafana, Loki, Promtail, cAdvisor, Node Exporter"
	@echo "  make monitor-down   - Stop observability stack"
	@echo "  make monitor-status - Show observability stack status"
	@echo "  make clean          - Remove local cache artifacts"
	@echo "  make k8s-validate   - Offline Kubernetes manifest validation"
	@echo "  make ci-cd-show     - Show latest full CI/CD run details"
	@echo "  make deploy-manual  - Manual Ansible deploy (needs infra/ansible/inventory.ini)"
	@echo "  make rollback REF=<git_ref> - One-command rollback deploy"
	@echo "  make health EC2_HOST=<host> - Check deployed health endpoint"

setup:
	python3 -m venv .venv
	./.venv/bin/python -m pip install --upgrade pip
	./.venv/bin/pip install -r requirements.txt

up:
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

status:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f --tail=100

lint:
	$(PYTHON) -m ruff check tests db.py

test:
	$(PYTHON) -m pytest -q

ci-check:
	$(PYTHON) -m ruff check tests db.py
	$(PYTHON) -m pytest -q
	$(PYTHON) scripts/check_env_parity.py
	$(COMPOSE) config > /dev/null
	docker build -t smart-hostel:local-check .

parity-check:
	$(PYTHON) scripts/check_env_parity.py

monitor-up:
	$(OBS_COMPOSE) up -d prometheus grafana loki promtail cadvisor node-exporter

monitor-down:
	$(OBS_COMPOSE) stop prometheus grafana loki promtail cadvisor node-exporter
	$(OBS_COMPOSE) rm -f prometheus grafana loki promtail cadvisor node-exporter

monitor-status:
	$(OBS_COMPOSE) ps

clean:
	rm -rf __pycache__ .pytest_cache .ruff_cache
	find . -type d -name __pycache__ -prune -exec rm -rf {} +
	find . -type f -name '*.pyc' -delete

k8s-validate:
	docker run --rm -v "$$(pwd)":/work -w /work ghcr.io/yannh/kubeconform:latest \
	  -summary -strict -ignore-missing-schemas infra/k8s/*.yaml

ci-cd-show:
	RID=$$(gh run list --repo $(REPO) --workflow ci.yml --limit 1 --json databaseId --jq '.[0].databaseId'); \
	gh run view $$RID --repo $(REPO) --json status,conclusion,url,jobs

health:
	if [ -z "$(EC2_HOST)" ]; then echo "EC2_HOST is required"; exit 1; fi
	curl --fail "http://$(EC2_HOST):5000/debug/db"

deploy-manual:
	ansible-playbook -i infra/ansible/inventory.ini infra/ansible/deploy.yml \
	  --extra-vars "repo_url=https://github.com/Devydv/Smart-Hoste.git repo_branch=main app_dir=/opt/smart_hostel install_packages=false"

rollback:
	if [ -z "$(REF)" ]; then echo "REF is required, e.g. make rollback REF=v1.0-deploy-green"; exit 1; fi
	ansible-playbook -i infra/ansible/inventory.ini infra/ansible/deploy.yml \
	  --extra-vars "repo_url=https://github.com/Devydv/Smart-Hoste.git repo_branch=$(REF) app_dir=/opt/smart_hostel install_packages=false enable_observability=true"
