variable "name_prefix" {
  description = "Prefix used for naming security group resources."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC that will own the security group."
  type        = string
}

variable "ingress_cidr_blocks" {
  description = "CIDR blocks allowed to access the web server on ports 80 and 443."
  type        = list(string)

  validation {
    condition     = length(var.ingress_cidr_blocks) > 0
    error_message = "At least one ingress CIDR block must be provided."
  }

  validation {
    condition     = alltrue([for cidr in var.ingress_cidr_blocks : can(cidrhost(cidr, 0))])
    error_message = "Each ingress CIDR block must be a valid IPv4 CIDR."
  }
}

variable "tags" {
  description = "Tags applied to security group resources."
  type        = map(string)
  default     = {}
}
