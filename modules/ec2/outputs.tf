output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.this.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance."
  value       = aws_instance.this.arn
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance."
  value       = aws_instance.this.private_ip
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance, if assigned."
  value       = aws_instance.this.public_ip
}

output "security_group_id" {
  description = "ID of the security group created by this module, if enabled."
  value       = try(aws_security_group.this[0].id, null)
}

output "security_group_ids" {
  description = "All security group IDs attached to the instance."
  value       = local.effective_security_group_ids
}

output "key_pair_name" {
  description = "Key pair name attached to the instance."
  value       = local.instance_key_name
}

output "key_pair_id" {
  description = "ID of the key pair created by this module, if enabled."
  value       = try(aws_key_pair.this[0].id, null)
}
