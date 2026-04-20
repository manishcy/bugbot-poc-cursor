data "aws_availability_zones" "available" {
  state = "available"
}

check "region_has_two_azs" {
  assert {
    condition     = length(data.aws_availability_zones.available.names) >= 2
    error_message = "The selected AWS region must expose at least two availability zones."
  }
}

check "selected_az_count" {
  assert {
    condition     = length(local.selected_azs) == 2
    error_message = "Exactly two availability zones must be selected for this configuration."
  }
}

check "selected_azs_are_unique" {
  assert {
    condition     = length(distinct(local.selected_azs)) == 2
    error_message = "The selected availability zones must be unique."
  }
}

module "network" {
  source = "./modules/network"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  azs                  = local.selected_azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.common_tags
}

module "web_security_group" {
  source = "./modules/web_security_group"

  name_prefix         = local.name_prefix
  vpc_id              = module.network.vpc_id
  ingress_cidr_blocks = var.web_ingress_cidr_blocks
  tags                = local.common_tags
}