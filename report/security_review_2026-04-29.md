# Security Review - 2026-04-29

Repository security review performed against the current `master` branch.

## Findings

### 1. Critical - Open SSH ingress from the internet

- OWASP: A05:2021 Security Misconfiguration
- File: `terraform/main.tf`
- Lines: 1-10

The Terraform security group allows inbound SSH from `0.0.0.0/0`, which exposes port 22 to the entire internet.

```hcl
resource "aws_security_group" "bad_sg" {
  name = "bad_sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

Recommended fix:

- Remove direct SSH access from the public internet.
- Use AWS Systems Manager Session Manager or restrict access to a trusted corporate/VPN CIDR.

Example:

```hcl
resource "aws_security_group" "web_sg" {
  name = "web_sg"
}

resource "aws_vpc_security_group_ingress_rule" "ssh_admin" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = "203.0.113.10/32"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  description       = "Restricted SSH admin access"
}
```

### 2. High - Unvalidated webhook URL can exfiltrate data

- OWASP: A10:2021 Server-Side Request Forgery
- File: `bot/bugbot.js`
- Lines: 4, 34-46

The script reads `SLACK_WEBHOOK` from the environment and posts findings to it without validating the destination host or scheme.

Recommended fix:

- Parse the URL before use.
- Enforce `https`.
- Allowlist `hooks.slack.com`.
- Disable redirects.

Example:

```js
const webhookUrl = new URL(process.env.SLACK_WEBHOOK);

if (webhookUrl.protocol !== "https:" || webhookUrl.hostname !== "hooks.slack.com") {
  throw new Error("Invalid Slack webhook URL");
}

await axios.post(webhookUrl.toString(), { text }, {
  timeout: 5000,
  maxRedirects: 0,
});
```

### 3. Medium - CI supply-chain integrity risk

- OWASP: A08:2021 Software and Data Integrity Failures
- Files:
  - `.github/workflows/bugbot.yml`
  - `package.json`

The workflow uses floating major tags for GitHub Actions and runs `npm install` without a committed dependency lockfile.

Recommended fix:

- Pin actions to full commit SHAs.
- Commit `package-lock.json`.
- Replace `npm install` with `npm ci`.

### 4. Medium - Kubernetes deployment is under-hardened

- OWASP: A05:2021 Security Misconfiguration
- File: `k8s/deployment.yaml`
- Lines: 1-12

The deployment uses an unpinned `nginx` image and lacks resource limits and container hardening controls.

Recommended fix:

- Pin the image to an immutable digest.
- Add resource requests and limits.
- Add a restrictive `securityContext`.

### 5. Low - Bug scanner logic is shallow and easy to evade

- OWASP: A04:2021 Insecure Design
- File: `bot/bugbot.js`
- Lines: 8-28

The Terraform scan only checks `./terraform/main.tf` for a literal `0.0.0.0/0` substring, which misses insecure values in other files or generated modules.

Recommended fix:

- Scan the full Terraform tree instead of a single file.
- Parse HCL or use a policy-as-code scanner rather than string matching.

## Summary

- Critical: 1
- High: 1
- Medium: 2
- Low: 1

Highest priority remediation:

1. Remove world-open SSH ingress from Terraform.
2. Validate the Slack webhook destination before posting.
3. Pin CI dependencies and GitHub Actions.
