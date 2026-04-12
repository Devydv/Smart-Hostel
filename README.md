# Smart Hostel Final

Smart Hostel Final is a Flask + MySQL application with full DevOps setup.

This README is a practical runbook for:
1. Which DevOps tools are used.
2. Which files were created for each tool.
3. What each file does.
4. How CI/CD pipeline runs.
5. How to run and verify everything end-to-end.

## 1. DevOps Pipeline Overview

Code flow in this project:
1. Developer pushes code to GitHub.
2. GitHub Actions runs CI checks.
3. If CI passes and branch is main, CD starts.
4. CD connects to EC2 via SSH and runs Ansible.
5. Ansible updates app and restarts containers.
6. Pipeline runs HTTP health check to confirm deployment.

## 2. DevOps Tools Used

| Tool | Where used | Why used |
| --- | --- | --- |
| Git | Entire repo | Version control and history |
| GitHub | Remote repo | Collaboration, PRs, secrets, Actions |
| GitHub Actions | .github/workflows/ci.yml | CI/CD automation |
| Docker | Dockerfile | Build app image |
| Docker Compose | docker-compose.yml | Run app + MySQL stack |
| Ruff | CI step | Python linting |
| Pytest | CI step | Automated testing |
| Trivy | CI step | Security scan |
| Terraform | infra/terraform | Provision EC2 and security group |
| Terraform bootstrap | infra/terraform/bootstrap | Create S3 backend + DynamoDB lock table |
| Ansible | infra/ansible/deploy.yml | Remote deployment automation |
| Kubernetes | infra/k8s | K8s manifests for cluster deployment |

## 3. DevOps File Inventory (What Each File Does)

### 3.1 CI/CD and Repository Files

| File | Purpose |
| --- | --- |
| .github/workflows/ci.yml | Complete CI/CD workflow: lint, test, build, scan, deploy, health-check |
| .gitignore | Ignores local/generated files from git tracking |
| .dockerignore | Reduces Docker build context by excluding unnecessary files |

### 3.2 Container and Runtime Files

| File | Purpose |
| --- | --- |
| Dockerfile | Defines how the Flask app image is built |
| docker-compose.yml | Defines app + MySQL services, networking, env, startup |
| requirements.txt | Python dependency list used in local/CI/container installs |

### 3.3 Database Provisioning File

| File | Purpose |
| --- | --- |
| infra/sql/init.sql | Creates schema and seed data for MySQL |

### 3.4 Terraform Main Stack Files

| File | Purpose |
| --- | --- |
| infra/terraform/providers.tf | Terraform and AWS provider configuration |
| infra/terraform/variables.tf | Input variable definitions |
| infra/terraform/main.tf | Main infrastructure resources |
| infra/terraform/outputs.tf | Output values after apply |
| infra/terraform/terraform.tfvars.example | Example variable values |
| infra/terraform/backend.hcl.example | Example remote backend config |
| infra/terraform/backend.hcl | Active backend config used in this workspace |
| infra/terraform/.terraform.lock.hcl | Provider version lock file |

### 3.5 Terraform Bootstrap Files

| File | Purpose |
| --- | --- |
| infra/terraform/bootstrap/main.tf | Creates S3 bucket and DynamoDB lock table |
| infra/terraform/bootstrap/providers.tf | Bootstrap provider configuration |
| infra/terraform/bootstrap/variables.tf | Bootstrap variable definitions |
| infra/terraform/bootstrap/outputs.tf | Outputs backend values for main stack |
| infra/terraform/bootstrap/terraform.tfvars.example | Example bootstrap values |
| infra/terraform/bootstrap/README.md | Bootstrap usage guide |
| infra/terraform/bootstrap/.terraform.lock.hcl | Provider lock file for bootstrap stack |

### 3.6 Ansible Files

| File | Purpose |
| --- | --- |
| infra/ansible/deploy.yml | Deploy playbook: optional package install, docker service checks, repo update, compose up |
| infra/ansible/inventory.ini.example | Example inventory format for manual deploy |

### 3.7 Kubernetes Manifest Files

| File | Purpose |
| --- | --- |
| infra/k8s/namespace.yaml | Creates namespace |
| infra/k8s/mysql-secret.example.yaml | MySQL secret template |
| infra/k8s/mysql-init-configmap.yaml | MySQL init SQL configmap |
| infra/k8s/mysql-pvc.yaml | Persistent storage claim for MySQL |
| infra/k8s/mysql-deployment.yaml | MySQL deployment |
| infra/k8s/mysql-service.yaml | MySQL service |
| infra/k8s/app-secret.example.yaml | App secret template |
| infra/k8s/app-configmap.yaml | App config values |
| infra/k8s/app-deployment.yaml | Flask app deployment |
| infra/k8s/app-service.yaml | Flask app NodePort service |

### 3.8 Generated Files (Do Not Edit Manually)

Generated during terraform runs:
1. .terraform/ directories
2. terraform.tfstate
3. terraform.tfstate.backup

These are state/runtime artifacts, not source code.

## 4. CI/CD Workflow Details

Pipeline file: .github/workflows/ci.yml

Triggers:
1. push to main and dev
2. pull_request

### CI Job: test-build-scan

Steps:
1. Checkout
2. Setup Python
3. Install dependencies
4. Ruff lint
5. Pytest
6. Docker build
7. Trivy scan

### CD Job: deploy-ec2

Runs only for push on main and only after CI success.

Steps:
1. Checkout
2. Setup Python
3. Install Ansible
4. Validate secrets
5. Write SSH key file
6. Write temporary inventory
7. SSH precheck with retries
8. Run ansible-playbook with timeout
9. Run post-deploy health check

Required GitHub Secrets:
1. EC2_HOST
2. EC2_USER
3. EC2_SSH_PRIVATE_KEY

## 5. How to Run DevOps Tools

### 5.1 Local App with Docker Compose

```bash
docker compose up -d --build
docker compose ps
docker compose down
```

### 5.2 Terraform Bootstrap (One-Time)

```bash
cd infra/terraform/bootstrap
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```

### 5.3 Terraform Main Stack

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
cp backend.hcl.example backend.hcl
terraform init -migrate-state -backend-config=backend.hcl
terraform plan
terraform apply
```

### 5.4 Ansible Manual Deploy

```bash
cd infra/ansible
cp inventory.ini.example inventory.ini
ansible-playbook -i inventory.ini deploy.yml --extra-vars "install_packages=true"
```

Note:
1. CI/CD currently uses install_packages=false for faster repeat deployments and to avoid apt lock issues.

### 5.5 Kubernetes Apply

```bash
kubectl apply -f infra/k8s/namespace.yaml
kubectl apply -f infra/k8s/mysql-secret.example.yaml
kubectl apply -f infra/k8s/mysql-init-configmap.yaml
kubectl apply -f infra/k8s/mysql-pvc.yaml
kubectl apply -f infra/k8s/mysql-deployment.yaml
kubectl apply -f infra/k8s/mysql-service.yaml
kubectl apply -f infra/k8s/app-secret.example.yaml
kubectl apply -f infra/k8s/app-configmap.yaml
kubectl apply -f infra/k8s/app-deployment.yaml
kubectl apply -f infra/k8s/app-service.yaml
```

## 6. Validation Checklist

Run these checks to validate project + DevOps setup:

```bash
# Python
./.venv/bin/python -m ruff check tests db.py
./.venv/bin/python -m pytest -q

# Docker
docker compose config
docker build -t smart-hostel:local-check .

# Terraform
cd infra/terraform && terraform validate
cd infra/terraform/bootstrap && terraform validate

# Ansible
cd infra/ansible && ansible-playbook --syntax-check deploy.yml

# Kubernetes (requires a reachable current-context API server)
kubectl cluster-info
kubectl get namespace smart-hostel >/dev/null 2>&1 || kubectl create namespace smart-hostel
kubectl apply --dry-run=server -f infra/k8s
```

## 7. Deployment Health Check

After CD completes:

```bash
curl --fail http://<EC2_HOST>:5000/debug/db
```

If it returns success, deployment is healthy.

## 8. Security Notes

1. Do not commit private keys or cloud credentials.
2. Keep deployment credentials only in GitHub Secrets.
3. Rotate keys immediately if exposed.
4. Use remote Terraform state with locking.
5. Follow least-privilege IAM policy for Terraform and deployment access.

## 9. Professor Demo Script (Live Pipeline)

Use this section when your professor asks for a code change and full CI/CD demo.

### 9.1 Make a visible code change

1. Create a demo branch.
2. Change a visible template line or a small app behavior.
3. Save and stage changes.

```bash
git checkout -b demo/professor-change
git add .
git commit -m "Demo: professor requested change"
```

### 9.2 Run quick local checks

```bash
./.venv/bin/python -m ruff check tests db.py
./.venv/bin/python -m pytest -q
docker compose config
```

Expected result:
1. Lint passes.
2. Tests pass.
3. Compose config validates.

### 9.3 Trigger CI and explain stages

```bash
git push -u origin demo/professor-change
```

Show in GitHub Actions:
1. Lint stage
2. Test stage
3. Docker build stage
4. Trivy scan stage

### 9.4 Trigger CD and explain deployment

1. Create PR and merge to main.
2. After merge, show CD job stages in order:
3. Secret check
4. SSH precheck
5. Ansible deploy
6. Post-deploy health check

### 9.5 Verify production deployment

```bash
curl --fail http://<EC2_HOST>:5000/debug/db
```

Expected result:
1. HTTP success response.
2. Confirms app and DB connectivity on deployed server.

### 9.6 Emergency fallback during demo

If the professor asks for one more change:
1. Update one visible line.
2. Commit and push again.
3. Show pipeline reruns automatically.

If CD is delayed:
1. Show CI is green first.
2. Show CD is in progress and point to active step.
3. Finish by running the health-check curl command when CD completes.
