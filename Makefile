SHELL := /bin/bash

PYTHON ?= $(shell if [ -x ./.venv/bin/python ]; then echo ./.venv/bin/python; else echo python3; fi)
PIP ?= $(PYTHON) -m pip
COMPOSE ?= docker compose
EC2_HOST ?=
REPO ?= Devydv/Smart-Hostel

.DEFAULT_GOAL := help

.PHONY: help setup up down status logs lint test coverage ci-check clean health k8s-validate ci-cd-show parity-check backup restore

help:
	@echo "Available targets:"
	@echo "  make setup          - Create .venv and install Python dependencies"
	@echo "  make up             - Start local stack"
	@echo "  make down           - Stop local stack"
	@echo "  make status         - Show local stack status"
	@echo "  make logs           - Tail container logs"
	@echo "  make lint           - Run Ruff"
	@echo "  make test           - Run Pytest"
	@echo "  make coverage       - Run Pytest with coverage report"
	@echo "  make ci-check       - Lint + test + compose config + docker build"
	@echo "  make parity-check   - Validate local/CI/deploy environment parity"
	@echo "  make clean          - Remove local cache artifacts"
	@echo "  make backup         - Backup MySQL + Grafana data"
	@echo "  make restore        - Restore MySQL + Grafana data"
	@echo "  make k8s-validate   - Offline Kubernetes manifest validation"
	@echo "  make ci-cd-show     - Show latest full CI/CD run details"
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
	$(PYTHON) -m ruff check app.py tests db.py --ignore E701,E702

test:
	$(PYTHON) -m pytest -q

coverage:
	$(PYTHON) -m pytest --cov=app --cov=db --cov-report=term-missing --cov-report=xml

ci-check:
	$(PYTHON) -m ruff check app.py tests db.py --ignore E701,E702
	$(PYTHON) -m pytest -q
	$(PYTHON) scripts/check_env_parity.py
	$(COMPOSE) config > /dev/null
	docker build -t smart-hostel:local-check .

parity-check:
	$(PYTHON) scripts/check_env_parity.py

clean:
	rm -rf __pycache__ .pytest_cache .ruff_cache
	find . -type d -name __pycache__ -prune -exec rm -rf {} +
	find . -type f -name '*.pyc' -delete

backup:
	./scripts/backup.sh

restore:
	./scripts/restore.sh

k8s-validate:
	docker run --rm -v "$$(pwd)":/work -w /work ghcr.io/yannh/kubeconform:latest \
	  -summary -strict -ignore-missing-schemas infra/k8s/*.yaml

ci-cd-show:
	RID=$$(gh run list --repo $(REPO) --workflow ci.yml --limit 1 --json databaseId --jq '.[0].databaseId'); \
	gh run view $$RID --repo $(REPO) --json status,conclusion,url,jobs

health:
	if [ -z "$(EC2_HOST)" ]; then echo "EC2_HOST is required"; exit 1; fi
	curl --fail "http://$(EC2_HOST):5000/health"
