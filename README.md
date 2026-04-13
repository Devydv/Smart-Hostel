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

## Monitoring (Prometheus + Grafana)

After `make up`, monitoring services are available in separate containers:

1. Prometheus: http://localhost:9090
2. Grafana: http://localhost:3000
3. App metrics endpoint: http://localhost:5000/metrics

Grafana defaults come from environment variables:
1. `GRAFANA_ADMIN_USER` (default `admin`)
2. `GRAFANA_ADMIN_PASSWORD` (default `admin123`)

The Prometheus data source is auto-provisioned in Grafana.
The default dashboard `Smart Hostel Overview` is auto-provisioned and includes HTTP request rate, HTTP latency, and MySQL health panels.

If port 5000 is already in use on your machine, set `WEB_PORT` before starting:

```bash
WEB_PORT=5002 make up
```

Dashboard path after login:
1. Dashboards -> Smart Hostel -> Smart Hostel Overview

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
8. `make clean`
9. `make down`
10. `make health EC2_HOST=<host>`

## Project Map

1. App code: `app.py`, `db.py`, `templates/`, `static/`
2. Containers: `Dockerfile`, `docker-compose.yml`
3. CI/CD: `.github/workflows/ci.yml`
4. Infrastructure: `infra/terraform/`
5. Monitoring config: `infra/monitoring/`
6. Kubernetes manifests: `infra/k8s/`

## Documentation

1. Known-good baseline: `KNOWN_GOOD.md`
2. Advanced operations (Terraform, K8s, recovery): `docs/ADVANCED_OPERATIONS.md`
3. Terraform backend bootstrap only: `infra/terraform/bootstrap/README.md`

## CI/CD Summary

1. Push/PR triggers CI (lint, parity check, test, docker build).
2. Push to `main` triggers CD (Ansible deploy over SSH + health check).

Required repository secrets for CD:
1. `EC2_HOST`
2. `EC2_USER`
3. `EC2_SSH_PRIVATE_KEY`
