# AWS VPC Terraform Configuration

This Terraform configuration provisions a reusable AWS networking stack with:

- 1 VPC
- 2 public subnets across 2 availability zones
- 2 private subnets across 2 availability zones
- 1 internet gateway
- 1 NAT gateway with an elastic IP
- Public and private route tables with subnet associations
- A web security group that allows inbound HTTP and HTTPS

## Usage

1. Initialize Terraform:

   terraform init

2. Review the execution plan:

   terraform plan

3. Apply the configuration:

   terraform apply

## Notes

- The first two available availability zones in the selected region are used.
- The NAT gateway is created in the first public subnet, which provides outbound internet access for both private subnets.
- Update the default CIDR ranges in `variables.tf` if they overlap with existing networks.
