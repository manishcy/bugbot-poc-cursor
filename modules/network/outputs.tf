output "availability_zones" {
  description = "Availability zones used for the subnets."
  value       = var.availability_zones
}

output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets in availability zone order."
  value       = [for availability_zone in var.availability_zones : aws_subnet.public[availability_zone].id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets in availability zone order."
  value       = [for availability_zone in var.availability_zones : aws_subnet.private[availability_zone].id]
}

output "internet_gateway_id" {
  description = "ID of the internet gateway."
  value       = aws_internet_gateway.this.id
}

output "nat_gateway_id" {
  description = "ID of the NAT gateway."
  value       = aws_nat_gateway.this.id
}

output "nat_gateway_public_ip" {
  description = "Public IP address attached to the NAT gateway."
  value       = aws_eip.nat.public_ip
}

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "Private route table IDs keyed by availability zone."
  value       = { for availability_zone, route_table in aws_route_table.private : availability_zone => route_table.id }
}

output "web_security_group_id" {
  description = "ID of the web security group."
  value       = aws_security_group.web.id
}
