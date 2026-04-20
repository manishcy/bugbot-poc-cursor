output "security_group_id" {
  description = "ID of the web server security group."
  value       = aws_security_group.web.id
}
