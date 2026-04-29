## Title
Security review follow-up: fix SSRF, CI supply-chain, open ingress, and Kubernetes hardening gaps

## Summary
A security review of the current repository found multiple concrete issues across application code, CI/CD, Terraform, and Kubernetes configuration.

## Findings

### 1. High - SSRF / outbound exfiltration via unvalidated Slack webhook
- File: `bot/bugbot.js`
- Lines: 4, 34-46
- Issue: `SLACK_WEBHOOK` is used directly as an outbound URL without validating scheme/host.
- Risk: A poisoned or misconfigured webhook can exfiltrate findings to an attacker-controlled endpoint.

### 2. High - Open SSH ingress to the internet
- File: `terraform/main.tf`
- Lines: 1-9
- Issue: Security group allows port 22 from `0.0.0.0/0`.
- Risk: Global SSH exposure increases brute-force and exploitation risk.

### 3. Medium - Supply-chain integrity risk in GitHub Actions
- Files: `.github/workflows/bugbot.yml`, `package.json`
- Lines: workflow 11, 14, 18; package 13-15
- Issue: Floating action tags and `npm install` without a committed lockfile.
- Risk: Non-reproducible builds and higher exposure to compromised dependencies.

### 4. Medium - Kubernetes deployment is under-hardened
- File: `k8s/deployment.yaml`
- Lines: 1-12
- Issue: Mutable `nginx` image, no resource limits, no visible hardening controls.
- Risk: Weaker runtime isolation and operational resilience.

## Recommended actions
- Validate and allowlist the Slack webhook URL before posting.
- Replace world-open SSH ingress with restricted CIDRs or remove SSH entirely.
- Pin GitHub Actions by commit SHA and switch CI to `npm ci` with `package-lock.json`.
- Harden the Kubernetes Deployment with pinned images, security context, and resource requests/limits.

## Acceptance criteria
- [ ] `bot/bugbot.js` validates webhook scheme and host before `axios.post`
- [ ] `terraform/main.tf` no longer exposes SSH to `0.0.0.0/0`
- [ ] CI uses pinned actions and `npm ci`
- [ ] A JS lockfile is committed
- [ ] `k8s/deployment.yaml` pins the image and defines resource limits plus basic container hardening

## References
- `report/security_review_2026-04-29.md`
