data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  selected_azs = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, 2)

  common_tags = merge(
    {
      ManagedBy = "Terraform"
      Project   = var.name_prefix
    },
    var.common_tags
  )
}

module "network" {
  source = "./modules/network"

  name_prefix          = var.name_prefix
  vpc_cidr             = var.vpc_cidr
  azs                  = local.selected_azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.common_tags
}

module "web_security_group" {
  source = "./modules/web_security_group"

  name_prefix         = var.name_prefix
  vpc_id              = module.network.vpc_id
  ingress_cidr_blocks = var.web_ingress_cidr_blocks
  tags                = local.common_tags
}