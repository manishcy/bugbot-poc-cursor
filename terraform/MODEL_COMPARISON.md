# Model comparison: HCL accuracy and AWS best-practice adherence

This repository exposed three candidate implementations on remote branches. The table below compares them against the final implementation in this branch.

## Compared candidates

| Label | Source branch | Notes |
|---|---|---|
| Model 1 | `origin/cursor/aws-vpc-terraform-6728` | Nested under `terraform/aws-vpc/`; root `terraform/main.tf` remains insecure stub |
| Model 2 | `origin/cursor/terraform-aws-network-3e7a` | Modular root layout under `terraform/` |
| Model 3 | `origin/cursor/aws-terraform-vpc-2c1a` | Modular root layout under `terraform/` |

## Comparison table

| Criteria | Model 1 | Model 2 | Model 3 | Final implementation in this branch |
|---|---|---|---|---|
| HCL syntax / structural accuracy | Low | High | High | High |
| Fully satisfies requested resources at root `terraform/` path | No | Yes | Yes | Yes |
| Modular structure | Partial | Yes | Yes | Yes |
| Variable validation depth | Medium | Medium | Medium-high | High |
| Output completeness | Medium | Medium-high | High | High |
| Uses explicit route resources | Mixed | No | Yes | Yes |
| Uses modern standalone SG rule resources | Yes | No | No | Yes |
| Avoids insecure SSH `0.0.0.0/0` exposure | No | Yes | Yes | Yes |
| Handles AZ selection robustly | Medium | Medium | Medium-high | High |
| Cost-aware NAT design | Yes | Yes | Optional | Yes |
| Production guidance / readability | Medium | Medium | High | High |
| Overall AWS best-practice adherence | Low | Good | Good | Very good |

## Detailed assessment

| Model | Strengths | Gaps / risks | Verdict |
|---|---|---|---|
| Model 1 | Includes modular VPC and SG code in a nested folder; uses standalone SG rule resources in that nested implementation. | The repository root `terraform/main.tf` still contains an insecure SSH-open security group, so the branch does not reliably deliver the requested result at the expected path. The nested implementation also adds optional NAT toggling that was not required and increases surface area. | Not acceptable as submitted because the visible root configuration remains insecure and incomplete. |
| Model 2 | Clean module split, sensible defaults, exactly two public/private subnet CIDR validations, single NAT gateway for cost efficiency. | Uses inline SG rules instead of standalone rule resources; weaker validation around CIDR correctness and uniqueness; relies on route-table inline routes instead of dedicated `aws_route` resources, which are usually clearer for change management. | Good baseline, but not the strongest on provider-style best practices or validation rigor. |
| Model 3 | Stronger README and outputs, explicit `aws_route` resources, optional NAT support, environment tagging. | Uses inline SG rules; defaults AZs directly instead of deriving them dynamically at runtime unless overridden; CIDR validity checks are incomplete for subnet ranges and duplicate AZ handling is not enforced. | Best of the three existing candidates overall, but still leaves validation and SG resource modeling improvements on the table. |
| Final implementation | Root module plus two focused child modules; dynamic two-AZ selection with guard checks; explicit routes; modern SG rule resources; validated CIDRs and exact subnet counts; example tfvars, README, outputs, and predictable tagging. | Uses a single NAT gateway shared by both private subnets for cost efficiency rather than per-AZ NAT for maximum resilience. This is intentional for the stated requirements. | Best balance of correctness, readability, modularity, and AWS/Terraform best practices for the requested scope. |

## Best-practice decisions used in the final implementation

- Keep the root module small and composition-focused.
- Validate exact subnet counts, CIDR syntax, and two unique AZs.
- Derive two AZs dynamically when the caller does not provide them.
- Use explicit `aws_route` resources for route management clarity.
- Use standalone `aws_vpc_security_group_ingress_rule` and `aws_vpc_security_group_egress_rule` resources.
- Avoid SSH ingress entirely because the request only called for HTTP/HTTPS web access.
- Tag all resources consistently with `Project`, `Environment`, and `ManagedBy`.
- Expose practical outputs for downstream stacks.
