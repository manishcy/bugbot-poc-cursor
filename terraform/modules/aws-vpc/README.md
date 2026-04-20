# `aws-vpc` Terraform module

Opinionated module that provisions an AWS VPC suitable for a simple public-facing web workload:

- A VPC with DNS support and DNS hostnames enabled
- Two public and two private subnets spread across two Availability Zones
- An Internet Gateway for the public subnets
- One or more NAT Gateways (single shared, or one per AZ) backing the private subnets
- One public route table plus one private route table per AZ, with matching associations
- A web-tier security group allowing HTTP (80) and HTTPS (443) ingress and all egress

## Usage

```hcl
module "network" {
  source = "../../modules/aws-vpc"

  name               = "example"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]

  public_subnet_cidrs  = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]

  single_nat_gateway = true

  tags = {
    Environment = "dev"
    Owner       = "platform"
  }
}
```

## Inputs

| Name                   | Description                                                                | Type           | Default                              |
| ---------------------- | -------------------------------------------------------------------------- | -------------- | ------------------------------------ |
| `name`                 | Name prefix applied to all resources                                       | `string`       | n/a                                  |
| `vpc_cidr`             | IPv4 CIDR block for the VPC                                                | `string`       | `"10.0.0.0/16"`                      |
| `availability_zones`   | Exactly two AZs used for subnet placement                                  | `list(string)` | n/a                                  |
| `public_subnet_cidrs`  | Two CIDR blocks for the public subnets                                     | `list(string)` | `["10.0.0.0/24", "10.0.1.0/24"]`     |
| `private_subnet_cidrs` | Two CIDR blocks for the private subnets                                    | `list(string)` | `["10.0.10.0/24", "10.0.11.0/24"]`   |
| `enable_dns_support`   | Enable DNS resolution in the VPC                                           | `bool`         | `true`                               |
| `enable_dns_hostnames` | Enable DNS hostnames in the VPC                                            | `bool`         | `true`                               |
| `single_nat_gateway`   | Deploy one shared NAT Gateway (cost optimized) instead of one per AZ       | `bool`         | `true`                               |
| `web_ingress_cidrs`    | CIDR blocks allowed to reach the web SG on 80/443                          | `list(string)` | `["0.0.0.0/0"]`                      |
| `tags`                 | Extra tags merged onto every resource                                      | `map(string)`  | `{}`                                 |

## Outputs

| Name                      | Description                                          |
| ------------------------- | ---------------------------------------------------- |
| `vpc_id`                  | VPC ID                                               |
| `vpc_cidr_block`          | VPC CIDR block                                       |
| `public_subnet_ids`       | Public subnet IDs                                    |
| `private_subnet_ids`      | Private subnet IDs                                   |
| `internet_gateway_id`     | IGW ID                                               |
| `nat_gateway_ids`         | NAT Gateway IDs                                      |
| `nat_gateway_public_ips`  | Elastic IPs attached to the NAT Gateways             |
| `public_route_table_id`   | Public route table ID                                |
| `private_route_table_ids` | Private route table IDs                              |
| `web_security_group_id`   | Web-tier security group ID (HTTP/HTTPS ingress)      |

## Design notes / best practices

- Uses modern per-rule `aws_vpc_security_group_{ingress,egress}_rule` resources, which plan/apply cleaner than inline `ingress`/`egress` blocks on `aws_security_group`.
- `create_before_destroy` on the security group prevents outages when attached ENIs force replacement.
- One private route table **per AZ** means a per-AZ NAT Gateway deployment does not send cross-AZ traffic.
- DNS support and hostnames are on by default (required for most service discovery and VPC endpoints).
- All resources inherit a common tag set (`Name`, `ManagedBy`, `Module`) merged with caller-supplied `tags`.
- Input validations catch common misconfigurations (non-CIDR strings, wrong AZ/subnet counts) at plan time.
