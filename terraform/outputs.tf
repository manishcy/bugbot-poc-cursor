output "availability_zones" {
  description = "Availability zones used by the network module."
  value       = module.network.availability_zones
}

output "vpc_id" {
  description = "ID of the created VPC."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the created public subnets."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the created private subnets."
  value       = module.network.private_subnet_ids
}

output "internet_gateway_id" {
  description = "ID of the internet gateway attached to the VPC."
  value       = module.network.internet_gateway_id
}

output "nat_gateway_id" {
  description = "ID of the NAT gateway used by the private subnets."
  value       = module.network.nat_gateway_id
}

output "nat_gateway_public_ip" {
  description = "Public IP address attached to the NAT gateway."
  value       = module.network.nat_gateway_public_ip
}

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = module.network.public_route_table_id
}

output "private_route_table_ids" {
  description = "Private route table IDs keyed by availability zone."
  value       = module.network.private_route_table_ids
}

output "web_security_group_id" {
  description = "ID of the security group intended for web servers."
  value       = module.network.web_security_group_id
}
