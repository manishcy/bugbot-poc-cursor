locals {
  selected_availability_zones = var.availability_zones != null ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, 2)
}

module "network" {
  source = "../modules/network"

  name_prefix                = var.name_prefix
  vpc_cidr_block             = var.vpc_cidr_block
  availability_zones         = local.selected_availability_zones
  public_subnet_cidr_blocks  = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
  web_ingress_cidr_blocks    = var.web_ingress_cidr_blocks
  tags                       = var.tags
}