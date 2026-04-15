locals {
  identifier = coalesce(var.identifier, var.name)
}

resource "aws_db_subnet_group" "this" {
  name       = "${local.identifier}-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = merge(var.tags, { Name = "${local.identifier}-subnet-group" })
}

resource "aws_db_instance" "this" {
  identifier                   = local.identifier
  engine                       = "postgres"
  engine_version               = var.engine_version
  instance_class               = var.instance_class
  allocated_storage            = var.allocated_storage
  max_allocated_storage        = var.max_allocated_storage
  storage_type                 = "gp3"
  storage_encrypted            = true
  db_name                      = var.db_name
  username                     = var.username
  password                     = var.password
  port                         = var.port
  db_subnet_group_name         = aws_db_subnet_group.this.name
  vpc_security_group_ids       = var.security_group_ids
  backup_retention_period      = var.backup_retention_period
  backup_window                = var.backup_window
  maintenance_window           = var.maintenance_window
  multi_az                     = var.multi_az
  publicly_accessible          = var.publicly_accessible
  skip_final_snapshot          = var.skip_final_snapshot
  final_snapshot_identifier    = var.skip_final_snapshot ? null : coalesce(var.final_snapshot_identifier, "${local.identifier}-final-snapshot")
  delete_automated_backups     = true
  auto_minor_version_upgrade   = true
  deletion_protection          = var.deletion_protection
  performance_insights_enabled = var.performance_insights_enabled
  apply_immediately            = var.apply_immediately
  tags                         = merge(var.tags, { Name = local.identifier })
}
