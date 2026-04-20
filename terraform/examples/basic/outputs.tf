output "vpc_id" {
  description = "ID of the VPC."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = module.network.private_subnet_ids
}

output "web_security_group_id" {
  description = "Web-tier security group ID."
  value       = module.network.web_security_group_id
}

output "nat_gateway_public_ips" {
  description = "Elastic IPs used by NAT Gateways."
  value       = module.network.nat_gateway_public_ips
}
