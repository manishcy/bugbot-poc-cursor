output "vpc_id" {
  description = "Provisioned VPC ID."
  value       = module.vpc.vpc_id
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN."
  value       = module.ecs.cluster_arn
}

output "ecs_service_name" {
  description = "ECS service name."
  value       = module.ecs.service_name
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint."
  value       = module.rds.db_address
}

output "rds_port" {
  description = "RDS PostgreSQL port."
  value       = module.rds.db_port
}
