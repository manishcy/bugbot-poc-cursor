provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "../modules/network"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  allowed_web_cidrs    = var.allowed_web_cidrs
  tags                 = var.tags
}