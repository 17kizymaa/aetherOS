# Branch protection recommendations

Enable these settings on GitHub for the `main` branch:

- Require pull request reviews before merging (1 reviewer).
- Require status checks to pass before merging: `validate` (the workflow added in `.github/workflows/validate.yml`).
- Require branches to be up to date before merging.
- Do not allow force pushes to `main`.

These rules enforce G0–G3 (repo hygiene, profile/script checks) and prevent accidental merges of generated artifacts.