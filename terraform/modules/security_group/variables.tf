variable "security_group_name" {
  description = "Name of the security group."
  type        = string
}

variable "description" {
  description = "Description of the security group."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created."
  type        = string
}

variable "ingress_cidrs" {
  description = "CIDR blocks allowed to access HTTP and HTTPS."
  type        = list(string)

  validation {
    condition     = length(var.ingress_cidrs) > 0
    error_message = "Provide at least one ingress CIDR block."
  }
}

variable "tags" {
  description = "Tags to apply to the security group."
  type        = map(string)
  default     = {}
}
