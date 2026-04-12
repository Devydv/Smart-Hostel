# Smart Hostel Final

Smart Hostel Final is a Flask + MySQL hostel management app with CI/CD deployment to EC2.

## Quick Start (Daily Path)

1. Create the local Python environment.

```bash
make setup
```

2. Start local stack.

```bash
make up
```

3. Run quality checks.

```bash
make ci-check
```

4. Stop stack when done.

```bash
make down
```

## Daily Commands

Use one command surface for regular work:

```bash
make help
```

Most common targets:
1. `make setup`
2. `make up`
3. `make status`
4. `make lint`
5. `make test`
6. `make parity-check`
7. `make ci-check`
8. `make monitor-up`
9. `make monitor-status`
10. `make monitor-down`
11. `make clean`
12. `make down`
13. `make health EC2_HOST=<host>`

## Observability Stack (Prometheus + Grafana)

Start observability services:

```bash
make monitor-up
```

Check status:

```bash
make monitor-status
```

Stop observability services:

```bash
make monitor-down
```

Default local URLs:
1. App: http://localhost:5000
2. App metrics: http://localhost:5000/metrics
3. Prometheus: http://localhost:9090
4. Grafana: http://localhost:3000 (admin/admin)

## Rollback (One Command)

Rollback to any known-good tag/commit:

```bash
make rollback REF=<git_ref>
```

Example:

```bash
make rollback REF=v1.0-deploy-green
```

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
