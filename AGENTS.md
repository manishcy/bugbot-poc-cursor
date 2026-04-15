## Cursor Cloud specific instructions

This is a small Node.js proof-of-concept security scanner ("BugBot") that scans Terraform and Kubernetes config files for misconfigurations.

### Running the application

```bash
node bot/bugbot.js
```

This scans `terraform/main.tf` and `k8s/deployment.yaml`, writes results to `report/findings.json`, and optionally posts to Slack if `SLACK_WEBHOOK` env var is set.

### Key notes

- The project uses **Node.js** (CI targets Node 18; any Node >= 18 works) with **npm** as the package manager.
- The only runtime dependency is `axios` (for optional Slack webhook posting).
- There is no dev server or build step — the bot is a single-run CLI script.
- The `test` script in `package.json` is a placeholder (`exit 1`); there are no automated tests.
- The `SLACK_WEBHOOK` environment variable is optional; the bot runs fine without it (logs "No Slack webhook found").
