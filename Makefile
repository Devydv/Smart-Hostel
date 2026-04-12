SHELL := /bin/bash

PYTHON ?= ./.venv/bin/python
EC2_HOST ?=

.PHONY: help up down logs lint test ci-check health k8s-validate deploy-manual

help:
	echo "Available targets:"
	echo "  make up             - Start local stack (docker compose up -d --build)"
	echo "  make down           - Stop local stack"
	echo "  make logs           - Tail container logs"
	echo "  make lint           - Run Ruff"
	echo "  make test           - Run Pytest"
	echo "  make ci-check       - Lint + test + compose config + docker build"
	echo "  make k8s-validate   - Offline Kubernetes manifest validation"
	echo "  make deploy-manual  - Manual Ansible deploy (needs infra/ansible/inventory.ini)"
	echo "  make health EC2_HOST=<host> - Check deployed health endpoint"

up:
	docker compose up -d --build

down:
	docker compose down

logs:
	docker compose logs -f --tail=100

lint:
	$(PYTHON) -m ruff check tests db.py

test:
	$(PYTHON) -m pytest -q

ci-check:
	$(PYTHON) -m ruff check tests db.py
	$(PYTHON) -m pytest -q
	docker compose config > /dev/null
	docker build -t smart-hostel:local-check .

k8s-validate:
	docker run --rm -v "$$(pwd)":/work -w /work ghcr.io/yannh/kubeconform:latest \
	  -summary -strict -ignore-missing-schemas infra/k8s/*.yaml

health:
	if [ -z "$(EC2_HOST)" ]; then echo "EC2_HOST is required"; exit 1; fi
	curl --fail "http://$(EC2_HOST):5000/debug/db"

deploy-manual:
	ansible-playbook -i infra/ansible/inventory.ini infra/ansible/deploy.yml \
	  --extra-vars "repo_url=https://github.com/Devydv/Smart-Hoste.git repo_branch=main app_dir=/opt/smart_hostel install_packages=false"
