variable "project_name" {
  description = "Prefix used for naming resources."
  type        = string
  default     = "web-network"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Exactly two availability zones to use. Leave empty to auto-select the first two in the region."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.azs) == 0 || length(var.azs) == 2
    error_message = "azs must be empty or contain exactly 2 availability zones."
  }
}

variable "public_subnet_cidrs" {
  description = "Two CIDR blocks for public subnets, one per availability zone."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "public_subnet_cidrs must contain exactly 2 CIDR blocks."
  }
}

variable "private_subnet_cidrs" {
  description = "Two CIDR blocks for private subnets, one per availability zone."
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "private_subnet_cidrs must contain exactly 2 CIDR blocks."
  }
}

variable "allowed_web_cidrs" {
  description = "CIDR ranges allowed to access web ports (HTTP/HTTPS)."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
