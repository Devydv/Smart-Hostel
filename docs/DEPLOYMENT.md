# Deployment Runbook

Smart Hostel deploys to EC2 through GitHub Actions and Ansible.

## Pipeline Flow

1. CI job
   - Lint
   - Tests
   - Docker build
   - Push image to GHCR
2. CD job
   - SSH to EC2
   - Pull latest image
   - Start services with Docker Compose
   - Verify app and monitoring health

Workflow file: `.github/workflows/ci.yml`

## Required Secrets

1. `EC2_HOST`
2. `EC2_USER`
3. `EC2_SSH_PRIVATE_KEY`

## EC2 Network Requirements

Open inbound TCP ports in the instance security group:

1. 22 (SSH)
2. 5000 (App)
3. 3000 (Grafana)
4. 9090 (Prometheus)

## Manual Health Checks

From any machine with network access:

```bash
curl -fsS http://<EC2_HOST>:5000/health
curl -fsS http://<EC2_HOST>:9090/-/healthy
curl -fsS http://<EC2_HOST>:3000/api/health
```

## Operational Notes

1. Deploy playbook prunes unused Docker artifacts before pull to reduce disk pressure failures.
2. Monitoring validation runs after app health validation.