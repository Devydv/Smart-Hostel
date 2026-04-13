# Known-Good Baseline

- Date: 2026-04-13
- Baseline tag: pipeline-stable-2026-04-13
- Known-good commit: 1804a692502389c062fa0c76c759e77d0cfa26ec
- Known-good run: https://github.com/Devydv/Smart-Hostel/actions/runs/24323643954
- Workflow conclusion: success (CI and Deploy To EC2 passed)
- Active deployment host instance: i-079e4b573b797cd9d
- Active deployment host public IP: 44.211.121.148

## Notes

- CI validates lint, tests, parity checks, and Docker image build in .github/workflows/ci.yml.
- CD deploy pulls GHCR web image and deploys over SSH from .github/workflows/ci.yml.
- Deploy workflow now bootstraps Docker on fresh Ubuntu hosts when available via passwordless sudo.
