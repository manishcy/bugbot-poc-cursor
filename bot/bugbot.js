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