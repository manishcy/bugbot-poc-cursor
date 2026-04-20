# AWS VPC Terraform Configuration

Modular Terraform configuration that provisions a production-style AWS network:

- VPC (`/16` by default) with DNS support and hostnames enabled
- 2 public and 2 private subnets across 2 Availability Zones
- Internet Gateway attached to the VPC
- NAT Gateway (+ Elastic IP) in the first public subnet for private egress (optional)
- Public route table with a `0.0.0.0/0` route through the Internet Gateway
- Private route table with a `0.0.0.0/0` route through the NAT Gateway (when enabled)
- Route-table associations for all subnets
- Security group for a web server allowing HTTP (80) and HTTPS (443) ingress

## Layout

```
aws-vpc/
├── main.tf                    # Root composition: wires modules together
├── variables.tf               # Input variables for the root module
├── outputs.tf                 # Outputs surfaced from the root module
├── locals.tf                  # Common tags and naming helpers
├── providers.tf               # AWS provider configuration
├── versions.tf                # Terraform + provider version constraints
├── terraform.tfvars.example   # Example variable values
└── modules/
    ├── vpc/                   # VPC, subnets, IGW, NAT GW, route tables
    └── security/              # Web server security group
```

## Usage

```bash
cd terraform/aws-vpc
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
terraform apply
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `aws_region` | AWS region to deploy into | `string` | `us-east-1` |
| `project_name` | Name prefix for resources and tags | `string` | `web-app` |
| `environment` | Deployment environment (`dev`/`staging`/`prod`) | `string` | `dev` |
| `vpc_cidr` | CIDR block for the VPC | `string` | `10.0.0.0/16` |
| `availability_zones` | Two AZs to use | `list(string)` | `["us-east-1a", "us-east-1b"]` |
| `public_subnet_cidrs` | CIDR blocks for the 2 public subnets | `list(string)` | `["10.0.1.0/24", "10.0.2.0/24"]` |
| `private_subnet_cidrs` | CIDR blocks for the 2 private subnets | `list(string)` | `["10.0.11.0/24", "10.0.12.0/24"]` |
| `enable_nat_gateway` | Create a NAT Gateway for private egress | `bool` | `true` |
| `ingress_cidr_blocks` | CIDRs allowed to hit the web SG on 80/443 | `list(string)` | `["0.0.0.0/0"]` |
| `tags` | Additional tags merged into every resource | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | VPC ID |
| `vpc_cidr_block` | VPC CIDR block |
| `public_subnet_ids` | Public subnet IDs |
| `private_subnet_ids` | Private subnet IDs |
| `internet_gateway_id` | Internet Gateway ID |
| `nat_gateway_id` | NAT Gateway ID (null if disabled) |
| `public_route_table_id` | Public route table ID |
| `private_route_table_id` | Private route table ID |
| `web_security_group_id` | Web server security group ID |

## Notes

- The web server security group allows HTTP/HTTPS from `var.ingress_cidr_blocks` (default `0.0.0.0/0`).
  In production environments, restrict this to a CDN, load balancer, or office CIDR.
- Only one NAT Gateway is provisioned for cost efficiency. For highly-available workloads,
  extend the VPC module to create one NAT Gateway per AZ.
- No SSH rule is opened by design; bastions or SSM Session Manager are preferred.
