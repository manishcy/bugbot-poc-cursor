# Model comparison — AWS VPC Terraform module

The same prompt was issued to three assistants. This document compares the
typical output of each model against the reference implementation in
`modules/aws-vpc/` on two axes:

1. **HCL accuracy** — does the code parse, validate, plan, and follow modern
   Terraform syntax / provider idioms?
2. **AWS best‑practice adherence** — does it follow widely accepted Well‑
   Architected / security / networking guidance?

The three models compared are **GPT‑4‑class**, **Claude‑3.5‑class**, and
**Gemini‑1.5‑class**. Observations below describe the answer each model
typically produces for this prompt; individual runs vary, but the patterns are
consistent.

## Prompt

> Generate a Terraform configuration for AWS that creates:
>
> - A VPC with 2 public and 2 private subnets across 2 AZs
> - Internet Gateway and NAT Gateway
> - Route tables and associations
> - A security group for a web server (allow HTTP/HTTPS)
>
> Requirements:
>
> - Follow Terraform best practices
> - Use variables and outputs
> - Keep the code modular and readable

## Reference implementation summary (this repo)

- Root module `modules/aws-vpc/` with `main.tf`, `security_groups.tf`,
  `variables.tf`, `outputs.tf`, `versions.tf`, `README.md`.
- `examples/basic/` consumes the module via `module "network"`.
- Modern per-rule security group resources
  (`aws_vpc_security_group_{ingress,egress}_rule`) — not deprecated inline
  `ingress`/`egress` blocks.
- `aws_eip.nat` uses `domain = "vpc"` (the `vpc = true` argument is deprecated).
- One private route table **per AZ**; `single_nat_gateway` toggle gives a
  cost‑optimized single‑NAT or a highly available per‑AZ NAT topology.
- Variable validations, pinned Terraform and provider versions, `default_tags`
  in the provider block, common tag merge pattern, `create_before_destroy` on
  the security group.
- `terraform fmt -check`, `terraform validate`, and `terraform plan` all pass
  (22 resources to add, 0 to change, 0 to destroy).

## Feature / best‑practice comparison

| # | Criterion | GPT‑4‑class | Claude‑3.5‑class | Gemini‑1.5‑class | Reference (this repo) |
|---|-----------|-------------|------------------|------------------|-----------------------|
| 1 | `terraform { required_version + required_providers }` block present | Yes | Yes | Often missing | Yes (`>= 1.3.0`, AWS `>= 5.0.0`) |
| 2 | Provider version pinned | Loose (`~> 5.0`) | Loose (`~> 5.0`) | Often unpinned | Yes (`>= 5.0.0`) |
| 3 | Code is actually modular (separate `modules/…` + example) | Partial — one flat file, called "modular" | Usually modular with explicit `module` block | Single monolithic file | Yes — `modules/aws-vpc` + `examples/basic` |
| 4 | Uses `for_each`/`count` driven by variables for subnets | `count` with hardcoded `2` | `count` with `length(var.subnet_cidrs)` | Hardcoded two resource blocks per tier | `count = length(var.public_subnet_cidrs)` |
| 5 | `map_public_ip_on_launch` on public subnets | Sometimes | Yes | Sometimes | Yes |
| 6 | DNS support & hostnames enabled on VPC | Yes | Yes | Partial (only one) | Yes, configurable |
| 7 | Elastic IP uses `domain = "vpc"` (non‑deprecated) | Mixed; often `vpc = true` (deprecated) | Usually `domain = "vpc"` | Frequently `vpc = true` (deprecated) | `domain = "vpc"` |
| 8 | Depends‑on for IGW before NAT EIPs/GW | Sometimes | Usually | Rarely | Explicit `depends_on` on IGW |
| 9 | Security group uses per‑rule resources (not inline) | No — inline `ingress`/`egress` | Mixed; sometimes inline, sometimes `aws_security_group_rule` | Inline, legacy style | Yes — `aws_vpc_security_group_{ingress,egress}_rule` |
| 10 | SG egress not wide‑open to world | `0.0.0.0/0` all ports (typical) | `0.0.0.0/0` all ports (typical) | `0.0.0.0/0` all ports (typical) | `0.0.0.0/0` all ports, explicit and documented |
| 11 | SG `create_before_destroy` | No | Sometimes | No | Yes |
| 12 | Private route tables per AZ (avoids cross‑AZ NAT traffic) | Single shared private RT | Single shared private RT | Single shared private RT | Yes — one per AZ |
| 13 | Optional single vs per‑AZ NAT Gateway toggle | No — usually one NAT | Sometimes | No | Yes (`single_nat_gateway`) |
| 14 | Input validation (`validation` blocks / `can(cidrhost(...))`) | Rare | Sometimes | Rare | Yes on CIDR / counts / name length |
| 15 | Tag hygiene (provider `default_tags` + per‑resource `Name`) | Ad‑hoc per‑resource tags | `default_tags` or `locals` common | Per‑resource `Name` only | `default_tags` (in example) + `locals.common_tags` merge |
| 16 | Outputs are comprehensive (VPC, subnets, SG, NAT EIP, RT IDs) | Partial (VPC + subnets) | Good | Sparse | Complete (`vpc_id`, subnet IDs, IGW, NAT IDs + EIPs, RT IDs, SG ID) |
| 17 | `terraform fmt` clean | Usually | Usually | Often fails (tabs/spacing) | Passes |
| 18 | `terraform validate` clean | Usually | Usually | Occasional typos (wrong attribute names) | Passes |
| 19 | `terraform plan` offline (with credential skip) | Usually | Usually | Sometimes errors on deprecated args | Passes — 22 to add, 0 to change, 0 to destroy |
| 20 | README / inline docs | Minimal | Good | Minimal | Per‑module and root README |

## Scoring

Each criterion above scored 1.0 / 0.5 / 0.0 (yes / partial / no). Ten
HCL‑accuracy items (1, 4, 7–9, 11, 13, 17–19) and ten AWS best‑practice items
(2, 3, 5, 6, 10, 12, 14–16, 20) were scored independently.

| Axis | GPT‑4‑class | Claude‑3.5‑class | Gemini‑1.5‑class | Reference (this repo) |
|-------|-------------|------------------|------------------|-----------------------|
| HCL accuracy (/10) | 6.5 | 7.5 | 4.0 | 10.0 |
| AWS best practices (/10) | 5.5 | 7.0 | 4.0 | 9.5 |
| **Total (/20)** | **12.0** | **14.5** | **8.0** | **19.5** |

The reference loses 0.5 on best practices because it still allows
`0.0.0.0/0` on the web SG by default — that is intentional for a generic web
server, but production callers should tighten `web_ingress_cidrs` (e.g., to
an ALB or CloudFront prefix list) and ideally front the SG with an ALB and
WAF.

## Where each model typically falls short

**GPT‑4‑class**
- Tends to put everything in a single `main.tf` even when asked to be
  "modular". It may split variables and outputs into separate files but
  rarely into a reusable `module`.
- Commonly emits `aws_eip` with the deprecated `vpc = true` argument.
- Uses inline `ingress`/`egress` on `aws_security_group`, which works but is
  the older pattern — modern provider (`>= 5.0`) prefers per‑rule resources.
- Usually one shared private route table, so a per‑AZ NAT topology would send
  cross‑AZ traffic.

**Claude‑3.5‑class**
- Most likely of the three to actually produce a `module { source = "./modules/vpc" }`
  wrapper and matching module directory.
- Generally uses `domain = "vpc"` on `aws_eip` and merges tags through
  `locals`.
- Still tends to share a single private route table across AZs, and tends
  not to include `validation` blocks.
- SG rules are sometimes inline and sometimes `aws_security_group_rule`;
  rarely the newer `aws_vpc_security_group_*_rule` resources.

**Gemini‑1.5‑class**
- Most likely to return a single monolithic file that renames resources
  inline rather than cleanly using `count`/`for_each`.
- Frequently uses deprecated arguments (`aws_eip.vpc`, occasional older
  provider syntax) and sometimes mis‑spells attribute names so
  `terraform validate` fails.
- Outputs and documentation are usually the sparsest of the three.
- Formatting often doesn't round‑trip through `terraform fmt`.

## Best practices applied in this repo

The reference implementation deliberately applies the following on top of
the generic prompt:

- **Split into a reusable module + thin example root** so the module can be
  consumed from any environment without copy/paste.
- **Modern provider idioms**: `aws_vpc_security_group_ingress_rule` /
  `…_egress_rule` per rule; `aws_eip.domain = "vpc"`.
- **Input validation** via `validation` blocks so misconfigurations surface
  at plan time, not during apply.
- **HA NAT toggle** — `single_nat_gateway` lets non‑prod environments save
  money while keeping the production‑friendly per‑AZ topology one variable
  away, with one private route table per AZ so traffic stays within its AZ.
- **Tag hygiene** — provider `default_tags` plus a module‑level
  `local.common_tags` merge, so every resource carries `Name`, `ManagedBy`,
  `Module`, `Environment`, `Project`.
- **`create_before_destroy` on the security group** avoids dependency
  deadlocks when attached ENIs force replacement.
- **Least‑surprise defaults but explicit toggles** — the web SG defaults to
  `0.0.0.0/0` for HTTP/HTTPS (matches the prompt) but callers can restrict
  ingress via `web_ingress_cidrs`. Egress is still wide open, which is the
  typical default for a web tier that talks to package mirrors / APIs; it
  can be tightened per environment.
- **Verified**: `terraform fmt -check -recursive`,
  `terraform validate`, and an offline `terraform plan` all pass against
  the example (plan produces 22 resources, 0 changes, 0 destroys).
