module "vpc" {
  source = "./modules/vpc"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway
  tags                 = local.common_tags
}

module "web_security_group" {
  source = "./modules/security"

  name_prefix         = local.name_prefix
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = var.ingress_cidr_blocks
  tags                = local.common_tags
}
