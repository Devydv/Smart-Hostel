# Known-Good Baseline

- Date: 2026-04-13
- Baseline tag: pipeline-stable-2026-04-13
- Known-good commit: d7b08152f4bdd7368cc409820a96924c97a7f8d4
- Known-good run: https://github.com/Devydv/Smart-Hostel/actions/runs/24323451910
- Workflow conclusion: success (CI and Deploy To EC2 passed)
- Active deployment host instance: i-0fa2abc49971e7d8a
- Active deployment host public IP: 100.24.121.149

## Notes

- CI validates lint, tests, parity checks, and Docker image build in .github/workflows/ci.yml.
- CD deploy pulls GHCR web image and deploys over SSH from .github/workflows/ci.yml.
- Deploy workflow now bootstraps Docker on fresh Ubuntu hosts when available via passwordless sudo.
