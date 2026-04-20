terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ---------------------------------------------------------------
# VPC
# ---------------------------------------------------------------
module "vpc" {
  source = "../modules/vpc"

  name               = var.project_name
  cidr_block         = var.vpc_cidr_block
  availability_zones = var.availability_zones

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  single_nat_gateway = var.single_nat_gateway

  tags = var.tags
}

# ---------------------------------------------------------------
# Web Server Security Group
# ---------------------------------------------------------------
resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Allow inbound HTTP and HTTPS traffic"
  vpc_id      = module.vpc.vpc_id

  tags = merge(var.tags, { Name = "${var.project_name}-web-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  for_each = toset(var.web_ingress_cidr_ipv4)

  security_group_id = aws_security_group.web.id
  description       = "Allow HTTP from ${each.value}"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value

  tags = merge(var.tags, { Name = "${var.project_name}-http-ingress" })
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  for_each = toset(var.web_ingress_cidr_ipv4)

  security_group_id = aws_security_group.web.id
  description       = "Allow HTTPS from ${each.value}"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value

  tags = merge(var.tags, { Name = "${var.project_name}-https-ingress" })
}

resource "aws_vpc_security_group_egress_rule" "https_out" {
  security_group_id = aws_security_group.web.id
  description       = "Allow outbound HTTPS (API calls, package updates)"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = merge(var.tags, { Name = "${var.project_name}-https-egress" })
}

resource "aws_vpc_security_group_egress_rule" "http_out" {
  security_group_id = aws_security_group.web.id
  description       = "Allow outbound HTTP (package mirrors, redirects)"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = merge(var.tags, { Name = "${var.project_name}-http-egress" })
}
