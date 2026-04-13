# Known-Good Baseline

- Date: 2026-04-13
- Baseline tag: pipeline-stable-2026-04-13
- Known-good commit: cd19b3a2590c6fed93ad0a24b67e01677fec39d5
- Known-good run: https://github.com/Devydv/Smart-Hostel/actions/runs/24314629902
- Workflow conclusion: success (initial run + 2 reruns)
- Active deployment host instance: i-0705c01d7fb2e3f7c
- Active deployment host public IP: 3.235.19.13

## Notes

- CI validates lint, tests, parity checks, and Docker image build in .github/workflows/ci.yml.
- CD deploy pulls GHCR web image and deploys over SSH from .github/workflows/ci.yml.
