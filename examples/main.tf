terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  name = var.name

  common_tags = merge(
    var.common_tags,
    {
      NamePrefix = var.name
      ManagedBy  = "terraform"
    }
  )
}

module "vpc" {
  source = "../modules/vpc"

  name                 = local.name
  vpc_cidr             = var.vpc_cidr
  azs                  = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = true
  single_nat_gateway   = true

  tags = local.common_tags
}

resource "aws_security_group" "ecs_service" {
  name        = "${local.name}-ecs-sg"
  description = "Security group for ECS service tasks"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Application port"
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_app_ingress_cidrs
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name}-ecs-sg" })
}

resource "aws_security_group" "rds" {
  name        = "${local.name}-rds-sg"
  description = "Security group for PostgreSQL"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "PostgreSQL from ECS tasks"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_service.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name}-rds-sg" })
}

module "ecs" {
  source = "../modules/ecs"

  name                   = local.name
  container_name         = "${local.name}-app"
  container_image        = var.container_image
  container_port         = var.container_port
  desired_count          = var.desired_count
  cpu                    = var.task_cpu
  memory                 = var.task_memory
  assign_public_ip       = false
  subnet_ids             = module.vpc.private_subnet_ids
  security_group_ids     = [aws_security_group.ecs_service.id]
  execution_role_arn     = var.ecs_execution_role_arn
  task_role_arn          = var.ecs_task_role_arn
  enable_execute_command = var.enable_execute_command

  environment = {
    DB_HOST = module.rds.db_address
    DB_PORT = tostring(module.rds.db_port)
    DB_NAME = module.rds.db_name
    DB_USER = module.rds.db_username
  }

  tags = local.common_tags
}

module "rds" {
  source = "../modules/rds"

  name                    = local.name
  identifier              = "${local.name}-postgres"
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  max_allocated_storage   = var.db_max_allocated_storage
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  port                    = 5432
  subnet_ids              = module.vpc.private_subnet_ids
  security_group_ids      = [aws_security_group.rds.id]
  multi_az                = var.db_multi_az
  backup_retention_period = var.db_backup_retention_period
  deletion_protection     = var.db_deletion_protection
  skip_final_snapshot     = var.db_skip_final_snapshot
  publicly_accessible     = var.db_publicly_accessible

  tags = local.common_tags
}
