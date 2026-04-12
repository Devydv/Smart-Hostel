SHELL := /bin/bash

PYTHON ?= $(shell if [ -x ./.venv/bin/python ]; then echo ./.venv/bin/python; else echo python3; fi)
PIP ?= $(PYTHON) -m pip
COMPOSE ?= docker compose
EC2_HOST ?=
REPO ?= Devydv/Smart-Hoste

.DEFAULT_GOAL := help

.PHONY: help setup up down status logs lint test ci-check clean health k8s-validate deploy-manual ci-cd-show

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
	@echo "  make clean          - Remove local cache artifacts"
	@echo "  make k8s-validate   - Offline Kubernetes manifest validation"
	@echo "  make ci-cd-show     - Show latest full CI/CD run details"
	@echo "  make deploy-manual  - Manual Ansible deploy (needs infra/ansible/inventory.ini)"
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
	$(COMPOSE) config > /dev/null
	docker build -t smart-hostel:local-check .

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
