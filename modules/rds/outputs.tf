output "db_instance_id" {
  description = "RDS instance ID."
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "RDS instance ARN."
  value       = aws_db_instance.this.arn
}

output "db_address" {
  description = "RDS endpoint address."
  value       = aws_db_instance.this.address
}

output "db_name" {
  description = "Database name."
  value       = aws_db_instance.this.db_name
}

output "db_username" {
  description = "Master username."
  value       = aws_db_instance.this.username
}

output "db_port" {
  description = "RDS endpoint port."
  value       = aws_db_instance.this.port
}

output "db_subnet_group_name" {
  description = "DB subnet group name."
  value       = aws_db_subnet_group.this.name
}

output "db_instance_endpoint" {
  description = "RDS endpoint in host:port form."
  value       = aws_db_instance.this.endpoint
}

output "db_instance_port" {
  description = "RDS endpoint port."
  value       = aws_db_instance.this.port
}
