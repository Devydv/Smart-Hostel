# Smart Hostel Final

Smart Hostel Final is a Flask + MySQL hostel management app with CI/CD deployment to EC2.

## Quick Start (Daily Path)

1. Start local stack.

```bash
make up
```

2. Run quality checks.

```bash
make ci-check
```

3. Stop stack when done.

```bash
make down
```

## Daily Commands

Use one command surface for regular work:

```bash
make help
```

Most common targets:
1. `make up`
2. `make down`
3. `make lint`
4. `make test`
5. `make ci-check`
6. `make health EC2_HOST=<host>`

## Project Map

1. App code: `app.py`, `db.py`, `templates/`, `static/`
2. Containers: `Dockerfile`, `docker-compose.yml`
3. CI/CD: `.github/workflows/ci.yml`
4. Deployment: `infra/ansible/deploy.yml`
5. Infrastructure: `infra/terraform/`
6. Kubernetes manifests: `infra/k8s/`

## Documentation

1. Known-good baseline: `KNOWN_GOOD.md`
2. Daily workflow details: `docs/DAILY_WORKFLOW.md`
3. Advanced operations (Terraform, Ansible, K8s, recovery): `docs/ADVANCED_OPERATIONS.md`
4. Terraform backend bootstrap only: `infra/terraform/bootstrap/README.md`

## CI/CD Summary

1. Push/PR triggers CI (lint, test, offline k8s manifest validation, docker build).
2. Push to `main` triggers CD (Ansible deploy + health check).

Required repository secrets for CD:
1. `EC2_HOST`
2. `EC2_USER`
3. `EC2_SSH_PRIVATE_KEY`
