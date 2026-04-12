# Known-Good Baseline

- Date: 2026-04-12
- Baseline tag: pending-new-repo-bootstrap
- Known-good commit: pending
- Known-good run: pending (new repo: https://github.com/Devydv/Smart-Hostel)
- Workflow conclusion: pending
- Active deployment host instance: i-0705c01d7fb2e3f7c
- Active deployment host public IP: 44.193.212.4

## Notes

- CI validates lint, tests, parity checks, and Docker image build in .github/workflows/ci.yml.
- CD deploy pulls GHCR web image and deploys over SSH from .github/workflows/ci.yml.
