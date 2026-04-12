# Advanced Operations

Use this document for infrastructure and deployment operations.

## Deployment

Automated deploy is driven by:
1. `.github/workflows/ci.yml`
2. `infra/ansible/deploy.yml`

Manual deploy:

```bash
make deploy-manual
```

Health check:

```bash
make health EC2_HOST=<host>
```

## Offline Kubernetes Manifest Validation

Use cluster-independent schema validation:

```bash
make k8s-validate
```

CI uses kubeconform for the same purpose.

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

Quick recovery command:

```bash
ansible-playbook -i infra/ansible/inventory.ini infra/ansible/deploy.yml \
  --extra-vars "repo_url=https://github.com/Devydv/Smart-Hoste.git repo_branch=main app_dir=/opt/smart_hostel install_packages=false"
```

Then verify:

```bash
curl --fail http://<EC2_HOST>:5000/debug/db
```

## Known-Good Reference

Stable baseline is tracked in:
1. `KNOWN_GOOD.md`
