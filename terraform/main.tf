data "aws_availability_zones" "available" {
  state = "available"
}

check "az_count" {
  assert {
    condition     = length(data.aws_availability_zones.available.names) >= 2
    error_message = "At least two availability zones are required in the selected AWS region."
  }
}

locals {
  azs = var.availability_zones != null ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, 2)

  common_tags = merge(
    {
      Project   = var.project_name
      ManagedBy = "Terraform"
    },
    var.tags
  )
}

module "network" {
  source = "./modules/vpc"

  project_name         = var.project_name
  vpc_cidr_block       = var.vpc_cidr_block
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = local.azs
  tags                 = local.common_tags
}

module "web_security_group" {
  source = "./modules/security_group"

  security_group_name = "${var.project_name}-web-sg"
  description         = "Security group for web servers"
  vpc_id              = module.network.vpc_id
  ingress_cidrs       = var.web_ingress_cidrs
  tags                = local.common_tags
}