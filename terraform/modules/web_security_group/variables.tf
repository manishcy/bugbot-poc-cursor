variable "name_prefix" {
  description = "Prefix used for naming security group resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the security group should be created."
  type        = string
}

variable "ingress_cidr_blocks" {
  description = "CIDR ranges allowed for HTTP/HTTPS inbound traffic."
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to security group resources."
  type        = map(string)
  default     = {}
}
