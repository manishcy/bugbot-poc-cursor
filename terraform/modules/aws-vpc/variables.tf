variable "name" {
  description = "Name prefix applied to all resources created by the module."
  type        = string

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 32
    error_message = "The name prefix must be between 1 and 32 characters."
  }
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of exactly two Availability Zones to deploy subnets into."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "Exactly two availability zones must be provided."
  }
}

variable "public_subnet_cidrs" {
  description = "List of exactly two IPv4 CIDR blocks for the public subnets."
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Exactly two public subnet CIDR blocks must be provided."
  }
}

variable "private_subnet_cidrs" {
  description = "List of exactly two IPv4 CIDR blocks for the private subnets."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "Exactly two private subnet CIDR blocks must be provided."
  }
}

variable "enable_dns_support" {
  description = "Whether DNS resolution is supported in the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Whether instances launched in the VPC receive public DNS hostnames."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Provision a single shared NAT Gateway (cheaper, lower HA) instead of one per AZ."
  type        = bool
  default     = true
}

variable "web_ingress_cidrs" {
  description = "CIDR blocks permitted to reach the web server on 80/443. Defaults to the public internet."
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = length(var.web_ingress_cidrs) > 0
    error_message = "At least one ingress CIDR must be provided."
  }
}

variable "tags" {
  description = "Tags applied to every resource created by the module."
  type        = map(string)
  default     = {}
}
