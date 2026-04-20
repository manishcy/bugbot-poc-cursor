variable "aws_region" {
  description = "AWS region where networking resources are deployed."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project identifier used in resource names and tags."
  type        = string
  default     = "web-platform"
}

variable "environment" {
  description = "Deployment environment used in naming and tagging."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "stage", "prod"], var.environment)
    error_message = "environment must be one of: dev, test, stage, prod."
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
  description = "Optional list of exactly two Availability Zones. Leave null to auto-select the first two available AZs in the region."
  type        = list(string)
  default     = null

  validation {
    condition     = var.availability_zones == null || length(var.availability_zones) == 2
    error_message = "availability_zones must be null or contain exactly two AZ names."
  }
}

variable "public_subnet_cidrs" {
  description = "Two IPv4 CIDR blocks for the public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) == 2 && alltrue([for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "public_subnet_cidrs must contain exactly two valid IPv4 CIDR blocks."
  }

  validation {
    condition     = length(distinct(var.public_subnet_cidrs)) == 2
    error_message = "public_subnet_cidrs must contain two unique CIDR blocks."
  }
}

variable "private_subnet_cidrs" {
  description = "Two IPv4 CIDR blocks for the private subnets."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) == 2 && alltrue([for cidr in var.private_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "private_subnet_cidrs must contain exactly two valid IPv4 CIDR blocks."
  }

  validation {
    condition     = length(distinct(var.private_subnet_cidrs)) == 2
    error_message = "private_subnet_cidrs must contain two unique CIDR blocks."
  }
}

variable "web_ingress_cidr_blocks" {
  description = "IPv4 CIDR blocks allowed to reach the web server over HTTP and HTTPS."
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = length(var.web_ingress_cidr_blocks) > 0 && alltrue([for cidr in var.web_ingress_cidr_blocks : can(cidrhost(cidr, 0))])
    error_message = "web_ingress_cidr_blocks must contain one or more valid IPv4 CIDR blocks."
  }
}

variable "tags" {
  description = "Additional tags merged into all resources."
  type        = map(string)
  default     = {}
}
