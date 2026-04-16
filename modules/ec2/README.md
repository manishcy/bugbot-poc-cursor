# EC2 Terraform Module

Terraform module to provision:
- An EC2 instance
- A security group (optional, with configurable ingress/egress rules)
- A key pair (optional)

## Requirements

- Terraform `>= 1.5.0`
- AWS provider `>= 5.0, < 6.0`

## Usage

```hcl
module "ec2" {
  source = "./modules/ec2"

  ami_id        = "ami-0123456789abcdef0"
  instance_name = "app-server"
  subnet_id     = "subnet-0123456789abcdef0"

  create_security_group = true
  vpc_id                = "vpc-0123456789abcdef0"
  security_group_ingress_rules = [
    {
      description = "Allow SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["203.0.113.0/24"]
    }
  ]

  create_key_pair = true
  key_name        = "app-server-key"
  public_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ..."

  tags = {
    Environment = "dev"
    Project     = "infra"
  }
}
```

## Notes

- When `create_security_group = true`, `vpc_id` is required.
- When `create_key_pair = true`, both `key_name` and `public_key` are required.
- If `create_security_group = false`, pass existing security groups in `security_group_ids`.

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| ami_id | AMI ID to use for the EC2 instance. | `string` | n/a | yes |
| instance_type | EC2 instance type. | `string` | `"t3.micro"` | no |
| instance_name | Name tag value for the EC2 instance. | `string` | `"ec2-instance"` | no |
| subnet_id | Subnet ID in which to launch the instance. | `string` | `null` | no |
| availability_zone | Availability zone for the instance. | `string` | `null` | no |
| associate_public_ip_address | Whether to associate a public IP. | `bool` | `null` | no |
| user_data | User data script. | `string` | `null` | no |
| create_key_pair | Whether to create key pair. | `bool` | `false` | no |
| key_name | Key pair name. | `string` | `null` | no |
| public_key | Public key material. | `string` | `null` | no |
| create_security_group | Whether to create security group. | `bool` | `true` | no |
| security_group_name | Name for created security group. | `string` | `"ec2-instance-sg"` | no |
| security_group_description | Description for created security group. | `string` | `"Security group managed by Terraform module ec2"` | no |
| vpc_id | VPC ID for created security group. | `string` | `null` | no |
| security_group_ids | Existing security group IDs to attach. | `list(string)` | `[]` | no |
| security_group_ingress_rules | Ingress rules for created security group. | `list(object)` | `[]` | no |
| security_group_egress_rules | Egress rules for created security group. | `list(object)` | allow-all rule | no |
| tags | Tags applied to all resources. | `map(string)` | `{}` | no |
| instance_tags | Additional instance-only tags. | `map(string)` | `{}` | no |
| security_group_tags | Additional security-group-only tags. | `map(string)` | `{}` | no |
| key_pair_tags | Additional key-pair-only tags. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|---|---|
| instance_id | ID of the EC2 instance. |
| instance_arn | ARN of the EC2 instance. |
| instance_private_ip | Private IP of the EC2 instance. |
| instance_public_ip | Public IP of the EC2 instance. |
| security_group_id | Created security group ID, if enabled. |
| security_group_ids | All security groups attached to instance. |
| key_pair_name | Key pair name attached to instance. |
| key_pair_id | Created key pair ID, if enabled. |
