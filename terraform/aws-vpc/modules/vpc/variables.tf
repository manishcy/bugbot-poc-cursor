variable "name_prefix" {
  description = "Prefix used when naming and tagging resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones to distribute subnets across."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets (one per AZ)."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets (one per AZ)."
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether to create a NAT Gateway for private subnet egress."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to all resources in the module."
  type        = map(string)
  default     = {}
}
