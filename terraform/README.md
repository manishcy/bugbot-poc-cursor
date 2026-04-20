# AWS VPC Terraform configuration

This Terraform configuration provisions a modular AWS network stack with:

- One VPC with DNS support and hostnames enabled
- Two public subnets and two private subnets across two Availability Zones
- One Internet Gateway
- One NAT Gateway with an Elastic IP for private subnet egress
- Public and private route tables with subnet associations
- A web security group that allows HTTP and HTTPS ingress

## Structure

```text
terraform/
├── main.tf
├── locals.tf
├── outputs.tf
├── provider.tf
├── terraform.tfvars.example
├── variables.tf
├── versions.tf
└── modules/
    ├── network/
    └── web_security_group/
```

## Usage

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

## Best-practice notes

- Uses modules to separate networking and security-group concerns.
- Validates that exactly two subnet CIDRs and two Availability Zones are used.
- Enables DNS support and hostnames for EC2-friendly networking.
- Avoids opening SSH from the internet; the web security group only exposes 80 and 443.
- Uses dedicated security group rule resources for cleaner lifecycle behavior with AWS provider v5+.
- Uses a single NAT Gateway for cost efficiency; for higher resilience, extend the module to create one NAT Gateway per AZ.
