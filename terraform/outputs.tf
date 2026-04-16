output "vpc_id" {
  description = "ID of the created VPC."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = module.network.private_subnet_ids
}

output "internet_gateway_id" {
  description = "ID of the internet gateway."
  value       = module.network.internet_gateway_id
}

output "nat_gateway_id" {
  description = "ID of the NAT gateway."
  value       = module.network.nat_gateway_id
}

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = module.network.public_route_table_id
}

output "private_route_table_id" {
  description = "ID of the private route table."
  value       = module.network.private_route_table_id
}

output "web_security_group_id" {
  description = "ID of the web server security group."
  value       = module.network.web_security_group_id
}
