variable "aws_region" {
  description = "AWS region where resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix used when naming AWS resources."
  type        = string
  default     = "web"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Optional list of exactly two availability zones. When null, the first two available AZs in the region are used."
  type        = list(string)
  default     = null

  validation {
    condition     = var.availability_zones == null || length(var.availability_zones) == 2
    error_message = "availability_zones must be null or contain exactly two availability zones."
  }
}

variable "public_subnet_cidr_blocks" {
  description = "Exactly two CIDR blocks for the public subnets."
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]

  validation {
    condition     = length(var.public_subnet_cidr_blocks) == 2
    error_message = "public_subnet_cidr_blocks must contain exactly two CIDR blocks."
  }
}

variable "private_subnet_cidr_blocks" {
  description = "Exactly two CIDR blocks for the private subnets."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]

  validation {
    condition     = length(var.private_subnet_cidr_blocks) == 2
    error_message = "private_subnet_cidr_blocks must contain exactly two CIDR blocks."
  }
}

variable "web_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to access the web security group on ports 80 and 443."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
  }
}
