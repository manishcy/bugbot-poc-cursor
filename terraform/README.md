# Terraform — AWS VPC

This directory contains a reusable Terraform module and an example root
configuration that provisions a production-minded network baseline on AWS:

- A VPC sized by `vpc_cidr`
- Two public and two private subnets spread across two Availability Zones
- An Internet Gateway for the public subnets
- A NAT Gateway (single shared by default, or one per AZ) for the private subnets
- A public route table and one private route table per AZ, with associations
- A web-tier security group allowing HTTP (80) and HTTPS (443) ingress

## Layout

```
terraform/
├── modules/
│   └── aws-vpc/          # Reusable VPC + SG module
│       ├── main.tf
│       ├── security_groups.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── versions.tf
│       └── README.md
└── examples/
    └── basic/            # Minimal consumer of the module
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        ├── providers.tf
        ├── versions.tf
        └── terraform.tfvars.example
```

## Usage

```bash
cd terraform/examples/basic
cp terraform.tfvars.example terraform.tfvars   # edit as needed
terraform init
terraform fmt -check -recursive ..
terraform validate
terraform plan
terraform apply
```

See `modules/aws-vpc/README.md` for the full list of inputs and outputs and
the design notes behind the module.

## Model comparison

`model-comparison.md` in this directory compares three LLM responses to the
same prompt (HCL accuracy and AWS best-practice adherence) so this
implementation can be evaluated against them.
