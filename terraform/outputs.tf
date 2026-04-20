output "vpc_id" {
  description = "ID of the VPC."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets."
  value       = module.network.private_subnet_ids
}

output "internet_gateway_id" {
  description = "ID of the internet gateway."
  value       = module.network.internet_gateway_id
}

output "nat_gateway_ids" {
  description = "Map of NAT gateway IDs keyed by subnet index."
  value       = module.network.nat_gateway_ids
}

output "web_security_group_id" {
  description = "ID of the web server security group."
  value       = module.web_security_group.security_group_id
}
