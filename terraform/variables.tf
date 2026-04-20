variable "region" {
  description = "AWS region for resources."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix for resources."
  type        = string
  default     = "web-stack"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Exactly two availability zones for subnet placement."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "Provide exactly 2 availability zones."
  }
}

variable "public_subnet_cidrs" {
  description = "Exactly two CIDRs for public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Provide exactly 2 public subnet CIDRs."
  }
}

variable "private_subnet_cidrs" {
  description = "Exactly two CIDRs for private subnets."
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "Provide exactly 2 private subnet CIDRs."
  }
}

variable "common_tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
  }
}
