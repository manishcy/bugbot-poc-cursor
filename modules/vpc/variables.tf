variable "name" {
  description = "Name prefix applied to VPC resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones used for public and private subnets."
  type        = list(string)

  validation {
    condition     = length(var.azs) > 0
    error_message = "At least one availability zone is required."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets. Length must match azs."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) > 0
    error_message = "At least one public subnet CIDR is required."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets. Length must match azs."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) > 0
    error_message = "At least one private subnet CIDR is required."
  }
}

variable "map_public_ip_on_launch" {
  description = "Assign public IPs to instances launched into public subnets."
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Create NAT gateway resources for private subnet egress."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Create a single shared NAT gateway when enabled."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}
