# AGENTS.md

## Cursor Cloud specific instructions

**BugBot** is a Node.js security scanner that statically analyzes Terraform and Kubernetes IaC files for common misconfigurations.

### Running the application

```bash
node bot/bugbot.js
```

This reads `terraform/main.tf` and `k8s/deployment.yaml`, writes results to `report/findings.json`, and optionally posts to Slack if `SLACK_WEBHOOK` env var is set. The script must be run from the repository root (it uses relative paths).

### Key notes

- **No build step required** — the project is plain CommonJS JavaScript.
- **No test suite** — `npm test` is a placeholder that exits with code 1. There are no lint or type-check scripts configured.
- **Single dependency** — `axios` (used for optional Slack webhook posting).
- **No database or external services needed** — the scanner only reads local files.
- **CI uses Node 18** (see `.github/workflows/bugbot.yml`), but any Node.js >= 18 works.
- **`report/findings.json`** is regenerated on each run; changes to it should not be committed.
