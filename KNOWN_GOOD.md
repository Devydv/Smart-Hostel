# Known-Good Baseline

- Date: 2026-04-12
- Baseline tag: v1.0-deploy-green
- Known-good commit: 02a1933d6c746bbfda74b015b0b12aac02ea5fd6
- Known-good run: https://github.com/Devydv/Smart-Hoste/actions/runs/24297874454
- Workflow conclusion: success
- Active deployment host instance: i-0705c01d7fb2e3f7c
- Active deployment host public IP: 44.193.212.4

## Notes

- CI includes offline Kubernetes manifest validation via kubeconform in .github/workflows/ci.yml.
- CD deploy uses the hardened docker-compose v1 fallback in infra/ansible/deploy.yml.
