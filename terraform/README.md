# AWS Network Terraform Configuration

This Terraform configuration creates:

- 1 VPC
- 2 public subnets across 2 AZs
- 2 private subnets across 2 AZs
- 1 Internet Gateway
- 1 NAT Gateway (in the first public subnet)
- Public/private route tables and subnet associations
- A web security group allowing HTTP/HTTPS ingress

## Structure

- `main.tf` - Root composition and shared locals.
- `variables.tf` - Input variables and validations.
- `outputs.tf` - Root outputs.
- `provider.tf` / `versions.tf` - Provider and version constraints.
- `modules/network` - VPC, subnets, IGW/NAT, routing.
- `modules/web_security_group` - Web server security group.

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and customize values.
2. Initialize and validate:
   - `terraform init`
   - `terraform validate`
3. Review plan:
   - `terraform plan`
4. Apply:
   - `terraform apply`

## Notes

- By default, the first two available AZs in the selected region are used.
- A single NAT gateway is used for both private subnets to keep costs lower.
