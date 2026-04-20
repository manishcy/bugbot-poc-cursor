module "network" {
  source = "../../modules/aws-vpc"

  name               = var.name
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  single_nat_gateway = var.single_nat_gateway
  web_ingress_cidrs  = var.web_ingress_cidrs

  tags = {
    Environment = var.environment
  }
}
