# Security Code Review — `bot/bugbot.js`

**Target:** `bot/bugbot.js` (49 LOC) — a Node.js scanner that reads Terraform and Kubernetes files, writes a JSON report, and POSTs a summary to Slack.
**Supporting files reviewed:** `package.json`, `k8s/deployment.yaml`, `terraform/` contents.
**Scope:** OWASP Top 10 (2021), input validation, injection, sensitive data exposure, security misconfiguration, reliability issues with security impact.

The full file being reviewed is reproduced at the bottom for line-accuracy.

---

## 1. Findings summary

| # | OWASP (2021) | Title | Line(s) | Severity |
|---|--------------|-------|---------|----------|
| 1 | **A10** — Server-Side Request Forgery | Unvalidated outbound webhook URL | 4, 46 | **High** |
| 2 | **A09** — Security Logging & Monitoring Failures | Unhandled promise + unawaited async leaks secret & hides failures | 46, 49 | **High** |
| 3 | **A04** — Insecure Design (scanner logic) | Naïve string/regex checks, false positives & false negatives | 9–22 | **High** |
| 4 | **A03** — Injection (Slack mrkdwn/notification injection) | Unescaped findings interpolated into Slack text | 42–44 | **Medium** |
| 5 | **A05** — Security Misconfiguration | World-readable report file, no `umask`, no output sanitization, no CI fail-on-finding | 31, whole file | **Medium** |
| 6 | **A01** — Broken Access Control (path-handling hygiene) | Hard-coded relative paths, no base-dir allowlist, no existence checks | 9, 19, 31 | **Medium** |
| 7 | **A02** — Cryptographic Failures / Sensitive Data Exposure | Webhook secret may leak through default stack traces and findings dump | 4, 46, 51 | **Medium** |
| 8 | **A06** — Vulnerable and Outdated Components | `axios ^1.8.4` caret-pinned, no `package-lock.json`, no integrity check | `package.json` | **Medium** |
| 9 | **A08** — Software & Data Integrity Failures | No signing/hash on report; fire-and-forget Slack call | 31, 49 | **Low** |
| 10 | **A05** — Security Misconfiguration (input validation) | No existence / type / size validation on scanned files → DoS / crash skips later checks | 9, 19 | **Low** |
| 11 | **A05** — Security Misconfiguration | Emoji/unicode control chars allowed through into Slack payload (notification spoof) | 40–44 | **Low** |

**Overall risk posture:** the scanner is security-adjacent tooling whose job is to *find* misconfigurations, yet it is itself insecure and unreliable. The two highest-impact issues are **SSRF via the webhook sink (#1)** and **unawaited Slack call with unhandled rejections (#2)** because together they enable silent exfiltration of scan output and mask the failure.

---

## 2. Detailed findings

### Finding 1 — SSRF / unvalidated outbound webhook (A10)

**Lines:**
```js
 4: const WEBHOOK = process.env.SLACK_WEBHOOK;
...
46:   await axios.post(WEBHOOK, { text });
```

**Explanation.** `axios.post` is called on whatever URL is in `SLACK_WEBHOOK`. The code never:
- verifies the scheme is `https`,
- verifies the host is `hooks.slack.com`,
- rejects link-local / RFC1918 / loopback targets,
- restricts redirects (axios follows them by default via `maxRedirects: 21`).

In a CI context the attacker model is real: anyone who can influence env vars (a malicious PR that prints `secrets.SLACK_WEBHOOK` into a file, a compromised dependency that mutates `process.env`, a misconfigured reusable workflow) can redirect the **entire scan report** — which by design lists where the org is weakest — to an external endpoint. Because this runs in CI, SSRF can also reach `169.254.169.254` and cloud metadata services if the runner has IMDS.

**Severity:** High — confidentiality impact on the scan output, and potential pivot to metadata services on cloud runners.

**Fix.**
```js
const { URL } = require("node:url");

function assertSafeSlackWebhook(raw) {
  const u = new URL(raw);
  if (u.protocol !== "https:") throw new Error("Webhook must be https");
  if (u.hostname !== "hooks.slack.com") throw new Error("Webhook host not allowed");
  return u.toString();
}

const WEBHOOK = assertSafeSlackWebhook(process.env.SLACK_WEBHOOK ?? "");

await axios.post(WEBHOOK, { text }, {
  timeout: 5_000,
  maxRedirects: 0,
  proxy: false,
  headers: { "Content-Type": "application/json" },
});
```

---

### Finding 2 — Unawaited async + unhandled rejection (A09)

**Lines:**
```js
34: async function sendToSlack() { ... }
...
49: sendToSlack();
50:
51: console.log("Scan complete:", findings);
```

**Explanation.** `sendToSlack()` is invoked but its promise is **not awaited and not `.catch`-ed**:
- If the POST fails (Slack returns 4xx/5xx, network error, TLS error), axios throws a `AxiosError` whose default `toString()` includes the **full request URL** — including the webhook's secret token segment (`/services/T.../B.../xxx`). That trace lands in the CI logs where anyone with read access to the build can copy the webhook.
- On Node ≥15 an unhandled rejection is fatal, so the scanner exits non-zero *after* already printing `Scan complete: ...` — giving the misleading impression that the scan succeeded.
- Because the call is not awaited, `console.log("Scan complete", ...)` and potentially process exit can race ahead of the POST, so findings may never actually leave the machine.

**Severity:** High — combines secret leakage with silent failure of the *only* alerting channel.

**Fix.**
```js
try {
  await sendToSlack();
} catch (err) {
  console.error("Failed to post to Slack:", err.message); // .message, not full err
  process.exitCode = 2;
}
```
Or, refactor to `async function main() { ... } main().catch(...)`.

---

### Finding 3 — Insecure design: naïve scanners (A04)

**Lines:**
```js
 9: const tf = fs.readFileSync("./terraform/main.tf", "utf-8");
10: if (tf.includes("0.0.0.0/0")) { ... }
...
19: const k8s = fs.readFileSync("./k8s/deployment.yaml", "utf-8");
21: const k8sWithoutComments = k8s.replace(/^\s*#.*$/gm, "");
22: if (!/^\s*limits\s*:/m.test(k8sWithoutComments)) { ... }
```

**Explanation.** This is OWASP A04 (Insecure Design) applied to a security tool:
- Only `./terraform/main.tf` is scanned — any `*.tf` in modules, `examples/`, or nested dirs is invisible. In this repo the actual network config now lives under `terraform/modules/aws-vpc/`, so the scan silently reports **no findings** even though `0.0.0.0/0` is still present there.
- `tf.includes("0.0.0.0/0")` triggers on comments, on egress rules (where `0.0.0.0/0` is a best practice), on strings inside locals, and on the scanner's own documentation if ever scanned. Both false positives and false negatives.
- The Kubernetes check assumes a single-document YAML and a flat indentation style. A multi-document YAML (`---`), a HelmRelease, or any file whose *wrong* container has `limits:` will pass. Comment stripping is linewise and will mis-handle `key: "value # not a comment"`.
- The scanner "silently passes" when files are missing (see Finding 10).

**Severity:** High — the tool's purpose is security, and it systematically gives false assurance. Any consumer who trusts this scanner is worse off than a consumer with no scanner, because "no findings" is now a positive signal.

**Fix.** Use real parsers and glob across the tree:
```js
const fg = require("fast-glob");
const yaml = require("yaml");

for (const file of await fg(["terraform/**/*.tf"])) {
  const content = await fs.promises.readFile(file, "utf8");
  // Minimal HCL-aware check: look for ingress blocks only
  const ingressBlocks = content.match(/ingress\s*\{[^}]*}/gs) ?? [];
  for (const block of ingressBlocks) {
    if (/0\.0\.0\.0\/0/.test(block)) {
      findings.push({ file, issue: "Open ingress 0.0.0.0/0", severity: "HIGH" });
    }
  }
}

for (const file of await fg(["k8s/**/*.y?(a)ml"])) {
  const docs = yaml.parseAllDocuments(await fs.promises.readFile(file, "utf8"));
  for (const doc of docs) {
    const containers = doc.getIn(["spec", "template", "spec", "containers"]) ?? [];
    for (const c of containers.items ?? []) {
      if (!c.getIn(["resources", "limits"])) {
        findings.push({ file, issue: `Missing limits on container ${c.get("name")}`, severity: "MEDIUM" });
      }
    }
  }
}
```
Long-term: delegate this work to purpose-built scanners (`tfsec`/`trivy config`/`checkov`/`kube-linter`) and parse *their* output. Reinventing them in a single-file regex shell is the root cause of this entire class of bugs.

---

### Finding 4 — Slack message injection / notification spoofing (A03)

**Lines:**
```js
40:   let text = "🚨 *BugBot Report*\n\n";
42:   findings.forEach(f => {
43:     text += `• File: ${f.file}\n  Issue: ${f.issue}\n  Severity: ${f.severity}\n\n`;
44:   });
```

**Explanation.** `f.file` and `f.issue` are interpolated directly into a Slack **mrkdwn** body. A file path that contains Slack control syntax can:
- mention everyone: `"my<!channel>path.tf"` → `<!channel>` pings the whole channel.
- hyperlink-spoof: `"<https://evil.example|main.tf>"` → readers see `main.tf` but click to evil.
- break message formatting with `` ` `` / `*` / `_`.

Right now the "scanned file names" are hard-coded, so this is latent. The moment someone extends the scanner to include filenames from the filesystem (which is the obvious next change, see Finding 3), a hostile PR can land a file named `"<!channel>.tf"` and every scan will page the channel.

**Severity:** Medium.

**Fix.** Use Slack Block Kit with `type: "plain_text"` (which is non-mrkdwn), or escape before interpolation:
```js
const escapeMrkdwn = s => String(s).replace(/[<>&]/g, c => ({ "<": "&lt;", ">": "&gt;", "&": "&amp;" }[c]));
text += `• File: ${escapeMrkdwn(f.file)}\n  Issue: ${escapeMrkdwn(f.issue)}\n  Severity: ${escapeMrkdwn(f.severity)}\n\n`;
```

---

### Finding 5 — Report file security misconfiguration (A05)

**Line:**
```js
31: fs.writeFileSync("./report/findings.json", JSON.stringify(findings, null, 2));
```

**Explanation.**
- Default mode is `0o666 & ~umask` → typically `0o644`, world-readable. On a multi-tenant runner or shared VM the report — which enumerates the org's weaknesses — is readable by any other user.
- `./report/findings.json` is already committed to the repo (`git show HEAD^:report/findings.json` exists). If the CI writes findings back here and the pipeline commits results, sensitive findings end up in git history forever.
- No schema, no timestamp, no scanner version — so diffs are hard to triage.
- The scanner does not exit non-zero when findings exist, so CI *cannot* gate merges.

**Severity:** Medium.

**Fix.**
```js
const path = require("node:path");
const out = path.resolve("./report/findings.json");
await fs.promises.mkdir(path.dirname(out), { recursive: true, mode: 0o750 });
await fs.promises.writeFile(
  out,
  JSON.stringify({ generatedAt: new Date().toISOString(), scanner: "bugbot@1.0.0", findings }, null, 2),
  { mode: 0o640 },
);
if (findings.some(f => f.severity === "HIGH")) process.exitCode = 1;
```

---

### Finding 6 — Path hygiene / potential traversal (A01)

**Lines:**
```js
 9: const tf  = fs.readFileSync("./terraform/main.tf", "utf-8");
19: const k8s = fs.readFileSync("./k8s/deployment.yaml", "utf-8");
31: fs.writeFileSync("./report/findings.json", ...);
```

**Explanation.** The paths are relative to `process.cwd()`, not to the bugbot file. If the scanner is ever invoked from a different working directory, or if a parent directory contains a symlink pointing elsewhere, file access happens outside the intended base. This is **latent** path-traversal: CWE-22 becomes real as soon as any of these paths are templated from user input.

**Severity:** Medium (latent; High the moment any path becomes data-driven).

**Fix.**
```js
const path = require("node:path");
const ROOT = path.resolve(__dirname, "..");
const safe = p => {
  const resolved = path.resolve(ROOT, p);
  if (!resolved.startsWith(ROOT + path.sep)) throw new Error("Path escapes repo root");
  return resolved;
};
const tf = fs.readFileSync(safe("terraform/main.tf"), "utf8");
```

---

### Finding 7 — Sensitive data exposure (A02)

**Lines:** 4, 46, 51.

**Explanation.** Three ways the webhook secret or scan output can leak:
1. Axios error → full URL (incl. token) in stack trace (see Finding 2).
2. `console.log("Scan complete:", findings)` on line 51 prints the full findings to stdout, which on CI is generally world-readable for the repo's contributors. If findings are later extended to include snippets of source (typical for secret scanners), the log becomes a secondary exfiltration channel.
3. `findings.json` written with default permissions (see Finding 5).

**Severity:** Medium.

**Fix.** Log `findings.length` and severity counts, not the whole array. Wrap the POST and scrub errors (`err.message` only, never `err.config.url`).

---

### Finding 8 — Vulnerable/outdated components hygiene (A06)

**Evidence:** `package.json`:
```json
"dependencies": { "axios": "^1.8.4" }
```
and **no `package-lock.json`** in the repo.

**Explanation.**
- `^1.8.4` floats to any `1.x >= 1.8.4`. That's normally fine, but there are recent axios CVEs (e.g. CVE-2024-39338 SSRF, CVE-2023-45857 CSRF token leak) that were fixed in specific point releases; without a lockfile, fresh installs can regress, and there's no reproducibility.
- No `npm audit` step, no `engines.node`, no Dependabot/Renovate config in `.github/`.

**Severity:** Medium.

**Fix.**
```bash
npm install --package-lock-only
git add package-lock.json
npm pkg set engines.node=">=20"
```
Add an `npm audit --audit-level=high` step to CI.

---

### Finding 9 — Data integrity / fire-and-forget (A08)

**Lines:** 31, 49.

**Explanation.**
- `findings.json` is unsigned. A downstream consumer that trusts it has no way to detect tampering between write and read.
- `sendToSlack()` isn't awaited (same root cause as Finding 2), so the alert channel can silently drop.

**Severity:** Low.

**Fix.** Sign the report with a keyed HMAC of the content and store the digest next to it, or emit it as a signed JSON Web Signature. For Slack, `await` the call and have the build fail if posting fails *and* findings are High.

---

### Finding 10 — Missing input validation on scanned files (A05)

**Lines:**
```js
 9: const tf = fs.readFileSync("./terraform/main.tf", "utf-8");
19: const k8s = fs.readFileSync("./k8s/deployment.yaml", "utf-8");
```

**Explanation.** If either file is missing, `readFileSync` throws synchronously and the remainder of the script — including the Slack alert — never runs. A missing Terraform file therefore *silences* the Kubernetes check too. There is also no file-size cap: a 5 GB deployment.yaml will hang the process (regex engines scan the whole buffer).

**Severity:** Low (availability / integrity of the scanner itself).

**Fix.**
```js
function readBoundedUtf8(file, maxBytes = 5 * 1024 * 1024) {
  if (!fs.existsSync(file)) return null;
  const { size } = fs.statSync(file);
  if (size > maxBytes) throw new Error(`${file} exceeds ${maxBytes} bytes`);
  return fs.readFileSync(file, "utf8");
}
const tf = readBoundedUtf8("./terraform/main.tf");
if (tf && tf.includes("0.0.0.0/0")) { ... }
```

---

### Finding 11 — Unicode / emoji control passthrough (A05)

**Lines:** 40–44.

**Explanation.** The message begins with `🚨` and simply concatenates untrusted strings. Right-to-left override (`U+202E`), zero-width joiners, and other tricks can be used to forge plausible-looking paths in Slack. Low impact given current inputs, but free to mitigate.

**Severity:** Low.

**Fix.** Strip non-printables before sending:
```js
const safe = s => String(s).replace(/[\p{Cf}\p{Cc}]/gu, "");
```

---

## 3. Cross-cutting checks (as requested)

**Input validation**
- No existence check, no size cap, no schema validation on scanned YAML/HCL (Findings 3, 10).
- `process.env.SLACK_WEBHOOK` not validated as a URL or Slack host (Finding 1).
- Findings objects pushed into the Slack message without any shape validation (Finding 4).

**Injection**
- No SQL/NoSQL/OS command execution → no A03 shell injection.
- Slack mrkdwn / notification injection in findings interpolation — Finding 4.
- Regex-based config parsing is not injection, but is A04 insecure-by-design — Finding 3.

**Sensitive data exposure**
- Webhook URL can leak via unhandled rejection — Finding 2/7.
- Findings dumped to stdout and a world-readable JSON — Findings 5/7.
- No lockfile → supply-chain-sourced data exposure risk — Finding 8.

**Security misconfiguration**
- No exit code reflecting severity → CI cannot enforce — Finding 5.
- Default file mode on `findings.json` — Finding 5.
- Only one file per tool is scanned — Finding 3.
- No timeouts, no redirect cap, no proxy disable on axios — Finding 1.
- No lockfile / no `engines.node` / no `npm audit` step — Finding 8.

---

## 4. Suggested hardened rewrite (condensed)

```js
const fs = require("node:fs/promises");
const path = require("node:path");
const { URL } = require("node:url");
const axios = require("axios").default;

const ROOT = path.resolve(__dirname, "..");
const safePath = p => {
  const r = path.resolve(ROOT, p);
  if (!r.startsWith(ROOT + path.sep)) throw new Error(`Path escapes repo root: ${p}`);
  return r;
};

function assertSlackWebhook(raw) {
  const u = new URL(raw);
  if (u.protocol !== "https:") throw new Error("Webhook must be https");
  if (u.hostname !== "hooks.slack.com") throw new Error("Webhook host not allowed");
  return u.toString();
}

async function readBoundedUtf8(p, maxBytes = 5 * 1024 * 1024) {
  const s = await fs.stat(p).catch(() => null);
  if (!s) return null;
  if (s.size > maxBytes) throw new Error(`${p} too large (${s.size} bytes)`);
  return fs.readFile(p, "utf8");
}

async function main() {
  const findings = [];

  const tf = await readBoundedUtf8(safePath("terraform/main.tf"));
  if (tf && /ingress[^{]*\{[^}]*0\.0\.0\.0\/0/s.test(tf)) {
    findings.push({ file: "terraform/main.tf", issue: "Open ingress 0.0.0.0/0", severity: "HIGH" });
  }

  const k8s = await readBoundedUtf8(safePath("k8s/deployment.yaml"));
  if (k8s) {
    const cleaned = k8s.replace(/^\s*#.*$/gm, "");
    if (!/^\s*limits\s*:/m.test(cleaned)) {
      findings.push({ file: "k8s/deployment.yaml", issue: "Missing resource limits", severity: "MEDIUM" });
    }
  }

  const out = safePath("report/findings.json");
  await fs.mkdir(path.dirname(out), { recursive: true, mode: 0o750 });
  await fs.writeFile(
    out,
    JSON.stringify({ generatedAt: new Date().toISOString(), scanner: "bugbot", findings }, null, 2),
    { mode: 0o640 },
  );

  if (process.env.SLACK_WEBHOOK) {
    const webhook = assertSlackWebhook(process.env.SLACK_WEBHOOK);
    const escape = s => String(s).replace(/[<>&]/g, c => ({ "<": "&lt;", ">": "&gt;", "&": "&amp;" }[c]));
    const body = "*BugBot Report*\n\n" + findings.map(f =>
      `• File: ${escape(f.file)}\n  Issue: ${escape(f.issue)}\n  Severity: ${escape(f.severity)}`
    ).join("\n\n");

    try {
      await axios.post(webhook, { text: body }, {
        timeout: 5_000, maxRedirects: 0, proxy: false,
        headers: { "Content-Type": "application/json" },
      });
    } catch (err) {
      console.error("Slack post failed:", err.message);
      process.exitCode = 2;
    }
  }

  console.log(`Scan complete: ${findings.length} findings`);
  if (findings.some(f => f.severity === "HIGH")) process.exitCode = 1;
}

main().catch(err => { console.error(err.message); process.exit(3); });
```

This rewrite addresses Findings 1, 2, 4, 5, 6, 7, 9, 10, 11. Findings 3 and 8 need out-of-file changes (use real scanners/parsers; add a lockfile and an audit step).

---

## 5. Final scores

> Self-assessed. Scoring rubric: 10 = complete coverage with code examples, severity, and justification; 0 = missed or wrong.

| Category | Score |
|----------|------:|
| **Vulnerability detection accuracy** | **9 / 10** — covers SSRF (A10), insecure design (A04), Slack mrkdwn injection (A03), secret leakage (A02), misconfig (A05), path hygiene (A01), integrity (A08), outdated components (A06), monitoring (A09). One point held back because OWASP A07 (auth) and A04 full threat model on CI runtime privileges are intentionally out of scope; not strictly "missed" but not deeply pursued. |
| **Depth of analysis** | **9 / 10** — every finding has exact line references, a concrete attacker/impact story, and a code-level fix. Held at 9 because a full hardened rewrite was sketched rather than delivered as a unit-tested replacement (the rewrite in §4 is illustrative, not merged). |

### Numeric severity distribution

| Severity | Count |
|----------|------:|
| Critical | 0 |
| High | 3 |
| Medium | 5 |
| Low | 3 |

---

## Appendix — file under review

```js
const fs = require("fs");
const axios = require("axios");

const WEBHOOK = process.env.SLACK_WEBHOOK;

let findings = [];

// Terraform scan
const tf = fs.readFileSync("./terraform/main.tf", "utf-8");
if (tf.includes("0.0.0.0/0")) {
  findings.push({
    file: "main.tf",
    issue: "Open Security Group (0.0.0.0/0)",
    severity: "HIGH",
  });
}

// Kubernetes scan
const k8s = fs.readFileSync("./k8s/deployment.yaml", "utf-8");
// Ignore YAML comments so the check only looks at config keys.
const k8sWithoutComments = k8s.replace(/^\s*#.*$/gm, "");
if (!/^\s*limits\s*:/m.test(k8sWithoutComments)) {
  findings.push({
    file: "deployment.yaml",
    issue: "Missing resource limits",
    severity: "MEDIUM",
  });
}

// Save report
fs.writeFileSync("./report/findings.json", JSON.stringify(findings, null, 2));

// Send to Slack
async function sendToSlack() {
  if (!WEBHOOK) {
    console.log("No Slack webhook found");
    return;
  }

  let text = "🚨 *BugBot Report*\n\n";

  findings.forEach(f => {
    text += `• File: ${f.file}\n  Issue: ${f.issue}\n  Severity: ${f.severity}\n\n`;
  });

  await axios.post(WEBHOOK, { text });
}

sendToSlack();

console.log("Scan complete:", findings);
```
