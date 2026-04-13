# Advanced Operations

Use this document for infrastructure and deployment operations.

## Deployment

Automated deploy is driven by:
1. `.github/workflows/ci.yml`
2. `infra/ansible/deploy.yml` executed by the CD job on push to `main`

Health check:

```bash
make health EC2_HOST=<host>
```

For day-to-day local workflow and standard commands, use `README.md`.

## Offline Kubernetes Manifest Validation

Use cluster-independent schema validation:

```bash
make k8s-validate
```

## Terraform

Main stack:

```bash
cd infra/terraform
terraform init -migrate-state -backend-config=backend.hcl
terraform plan
terraform apply
```

Bootstrap backend resources:

```bash
cd infra/terraform/bootstrap
terraform init
terraform apply
```

Details are documented in `infra/terraform/bootstrap/README.md`.

## Recovery

Quick recovery command from the deployment host:

```bash
cd ~/smart_hostel
git fetch origin main
git checkout main
git reset --hard origin/main
docker compose up -d --build mysql web
```

Then verify:

```bash
curl --fail http://<EC2_HOST>:5000/health
```

## Known-Good Reference

Stable baseline is tracked in:
1. `KNOWN_GOOD.md`
