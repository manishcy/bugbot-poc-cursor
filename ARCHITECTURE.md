# BugBot POC Architecture

## Overview

**bugbot-poc** is a proof-of-concept CI security scanner that scans Terraform and Kubernetes files for security issues, generates a JSON findings report, and optionally posts summaries to Slack.

## Technology Stack

| Layer | Technology |
|-------|------------|
| Language | JavaScript (Node.js, CommonJS) |
| HTTP Client | axios |
| CI/CD | GitHub Actions (Ubuntu, Node 18) |
| IaC Examples | Terraform (AWS), Kubernetes |

## Project Structure

```
/
├── bot/
│   └── bugbot.js              # Main scanner script
├── terraform/
│   └── main.tf                # Example AWS security group (intentionally vulnerable)
├── k8s/
│   └── deployment.yaml        # Example K8s deployment (missing resource limits)
├── report/
│   └── findings.json          # Output: scan results
├── .github/workflows/
│   └── bugbot.yml             # CI pipeline definition
└── package.json               # npm config (axios dependency)
```

## Component Responsibilities

### `bot/bugbot.js`
The main scanner script with the following responsibilities:
1. **Terraform Scan**: Reads `terraform/main.tf` and checks for `0.0.0.0/0` patterns (open security groups) → HIGH severity
2. **Kubernetes Scan**: Reads `k8s/deployment.yaml` and checks for missing `limits:` configuration → MEDIUM severity
3. **Report Generation**: Writes findings to `report/findings.json`
4. **Slack Notification**: If `SLACK_WEBHOOK` environment variable is set, posts a formatted report to Slack

### `.github/workflows/bugbot.yml`
GitHub Actions workflow that:
- Triggers on every pull request
- Sets up Node.js 18 environment
- Installs dependencies
- Runs the scanner with optional Slack webhook from secrets

### Example Files
- `terraform/main.tf` - Contains an intentionally vulnerable AWS security group with `0.0.0.0/0` CIDR
- `k8s/deployment.yaml` - Contains an intentionally incomplete deployment missing resource limits

## Data Flow

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  GitHub PR  │────▶│  GitHub Actions  │────▶│  bot/bugbot.js  │
└─────────────┘     └──────────────────┘     └────────┬────────┘
                                                      │
                    ┌─────────────────────────────────┼─────────────────────────────────┐
                    │                                 │                                 │
                    ▼                                 ▼                                 ▼
           ┌────────────────┐              ┌──────────────────┐              ┌─────────────────┐
           │ terraform/     │              │ k8s/             │              │ report/         │
           │ main.tf        │              │ deployment.yaml  │              │ findings.json   │
           │ (read)         │              │ (read)           │              │ (write)         │
           └────────────────┘              └──────────────────┘              └─────────────────┘
                                                      │
                                                      ▼
                                           ┌──────────────────┐
                                           │  Slack Webhook   │
                                           │  (optional POST) │
                                           └──────────────────┘
```

## Architectural Patterns

- **Batch/Pipeline Step**: Single synchronous script designed to run in CI
- **Report Artifact**: JSON file as the durable output of each scan
- **Notification Adapter**: Optional Slack integration via webhook environment variable
- **Policy as Simple Checks**: String and regex-based rules for security scanning

## Security Checks

| Check | File | Pattern | Severity |
|-------|------|---------|----------|
| Open Security Group | `main.tf` | Contains `0.0.0.0/0` | HIGH |
| Missing Resource Limits | `deployment.yaml` | Missing `limits:` key | MEDIUM |

## Configuration

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `SLACK_WEBHOOK` | No | Slack incoming webhook URL for notifications |

### GitHub Actions Secrets

Configure `SLACK_WEBHOOK` in your repository secrets to enable Slack notifications.

## Running Locally

```bash
# Install dependencies
npm install

# Run the scanner
node bot/bugbot.js

# With Slack notifications
SLACK_WEBHOOK=https://hooks.slack.com/services/... node bot/bugbot.js
```

## Output

The scanner produces a JSON report at `report/findings.json`:

```json
[
  {
    "file": "main.tf",
    "issue": "Open Security Group (0.0.0.0/0)",
    "severity": "HIGH"
  },
  {
    "file": "deployment.yaml",
    "issue": "Missing resource limits",
    "severity": "MEDIUM"
  }
]
```
