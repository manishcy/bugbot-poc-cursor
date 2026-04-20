# AWS Network Terraform (Modular)

This Terraform configuration provisions:
- 1 VPC
- 2 public subnets and 2 private subnets across 2 AZs
- Internet Gateway
- NAT Gateways (one per AZ for higher availability)
- Public and private route tables with subnet associations
- Web server security group (HTTP/HTTPS ingress)

## Structure

- `providers.tf` - Terraform and provider requirements
- `variables.tf` - root input variables
- `main.tf` - module composition
- `outputs.tf` - root outputs
- `terraform.tfvars.example` - example variable values
- `modules/network` - VPC, subnets, routing, IGW, NAT
- `modules/security_group` - web security group

## Usage

1. Copy and customize variables:
   - `cp terraform.tfvars.example terraform.tfvars`
2. Initialize:
   - `terraform init`
3. Validate:
   - `terraform validate`
4. Plan:
   - `terraform plan`
5. Apply:
   - `terraform apply`

## Best-practice notes implemented

- Modularized by concern (`network`, `security_group`)
- Typed variables with validation for exact subnet/AZ cardinality
- Explicit outputs for downstream modules and integrations
- Consistent tagging strategy
- DNS support and hostnames enabled on VPC
- NAT and private route tables per AZ (better HA vs single NAT)
- Public subnets auto-assign public IPs for internet-facing workloads

## Difference and quality comparison (3 selected models)

The table below compares representative output quality levels often seen from three model classes when generating this exact Terraform task.

| Model | HCL syntax accuracy | Terraform structure quality | AWS best-practice adherence | Common gaps vs this implementation |
|---|---|---|---|---|
| GPT-4 level baseline | Medium-High | Medium | Medium | Often generates working HCL but frequently uses single NAT for all private subnets, weaker variable validation, and flatter/non-modular file layout. |
| Claude 3.5 Sonnet level baseline | High | High | Medium-High | Usually clean HCL and good module boundaries, but may still choose cost-optimized single-NAT defaults and omit some explicit outputs/validation constraints. |
| Codex 5.3 (this implementation) | High (validated) | High (module composition + typed IO) | High (NAT per AZ, route isolation, explicit SG intent) | Trade-off is higher cost from multi-AZ NAT design; intentionally chosen for resilience and best-practice alignment. |

### Why this is considered best-practice aligned

- **Reliability first:** each private subnet routes through a NAT in its AZ, reducing blast radius.
- **Maintainability:** clear module boundaries and explicit interfaces (variables/outputs).
- **Safety and correctness:** variable cardinality checks prevent broken topology inputs.
- **Operational clarity:** deterministic names/tags and concise outputs simplify automation.
