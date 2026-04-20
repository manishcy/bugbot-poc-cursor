variable "name_prefix" {
  description = "Prefix used when naming and tagging resources."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC in which to create the security group."
  type        = string
}

variable "ingress_cidr_blocks" {
  description = "CIDR blocks permitted to reach the web server on HTTP/HTTPS."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags applied to all resources in the module."
  type        = map(string)
  default     = {}
}
