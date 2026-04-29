# Terraform Bootstrap Backend

This directory is only for bootstrapping Terraform remote state resources.

## What It Creates

1. S3 bucket for Terraform state
2. DynamoDB table for state locking

## Steps

```bash
cd infra/terraform/bootstrap
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
terraform output backend_hcl_snippet
```

Use the output values to configure backend in `infra/terraform`:

```bash
cd ../
cp backend.hcl.example backend.hcl
# fill backend.hcl with values from backend_hcl_snippet
terraform init -migrate-state -backend-config=backend.hcl
```
