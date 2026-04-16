variable "name_prefix" {
  description = "Prefix used when naming AWS resources."
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Exactly two availability zones used for subnet placement."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "availability_zones must contain exactly two availability zones."
  }
}

variable "public_subnet_cidr_blocks" {
  description = "Exactly two CIDR blocks for the public subnets."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidr_blocks) == 2
    error_message = "public_subnet_cidr_blocks must contain exactly two CIDR blocks."
  }
}

variable "private_subnet_cidr_blocks" {
  description = "Exactly two CIDR blocks for the private subnets."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_cidr_blocks) == 2
    error_message = "private_subnet_cidr_blocks must contain exactly two CIDR blocks."
  }
}

variable "map_public_ip_on_launch" {
  description = "Whether public subnets should automatically assign public IPs to launched instances."
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Whether DNS support is enabled for the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Whether instances launched in the VPC receive public DNS hostnames."
  type        = bool
  default     = true
}

variable "web_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to access the web security group on ports 80 and 443."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "vpc_tags" {
  description = "Additional tags applied only to the VPC."
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags applied only to the public subnets."
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags applied only to the private subnets."
  type        = map(string)
  default     = {}
}

variable "internet_gateway_tags" {
  description = "Additional tags applied only to the internet gateway."
  type        = map(string)
  default     = {}
}

variable "nat_gateway_tags" {
  description = "Additional tags applied only to the NAT gateway and its Elastic IP."
  type        = map(string)
  default     = {}
}

variable "route_table_tags" {
  description = "Additional tags applied only to the route tables."
  type        = map(string)
  default     = {}
}

variable "security_group_tags" {
  description = "Additional tags applied only to the web security group."
  type        = map(string)
  default     = {}
}
