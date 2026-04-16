# Network Terraform Module

Terraform module to provision:
- A VPC
- Two public subnets across two availability zones
- Two private subnets across two availability zones
- An internet gateway
- A single NAT gateway with an Elastic IP
- Public and private route tables with subnet associations
- A web security group allowing HTTP and HTTPS

## Requirements

- Terraform `>= 1.5.0`
- AWS provider `>= 5.0, < 6.0`

## Usage

```hcl
module "network" {
  source = "../modules/network"

  name_prefix                = "demo"
  vpc_cidr_block             = "10.0.0.0/16"
  availability_zones         = ["us-east-1a", "us-east-1b"]
  public_subnet_cidr_blocks  = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnet_cidr_blocks = ["10.0.10.0/24", "10.0.11.0/24"]
  web_ingress_cidr_blocks    = ["0.0.0.0/0"]

  tags = {
    Environment = "dev"
    Project     = "networking"
  }
}
```

## Notes

- The module creates exactly two public subnets and two private subnets.
- A single NAT gateway is used for both private subnets to keep the design simple and cost-conscious.
- `web_ingress_cidr_blocks` controls access to ports `80` and `443`.

## Outputs

| Name | Description |
|---|---|
| availability_zones | Availability zones used for the subnets. |
| vpc_id | ID of the VPC. |
| vpc_cidr_block | CIDR block of the VPC. |
| public_subnet_ids | IDs of the public subnets in availability zone order. |
| private_subnet_ids | IDs of the private subnets in availability zone order. |
| internet_gateway_id | ID of the internet gateway. |
| nat_gateway_id | ID of the NAT gateway. |
| nat_gateway_public_ip | Public IP attached to the NAT gateway. |
| public_route_table_id | ID of the public route table. |
| private_route_table_ids | Private route table IDs keyed by availability zone. |
| web_security_group_id | ID of the web security group. |
