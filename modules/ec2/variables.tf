variable "name" {
  description = "Name for EC2 instance."
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}

variable "ami_id" {
  description = "AMI ID for EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet ID for EC2 instance."
  type        = string
}

variable "security_group_ids" {
  description = "Security groups for EC2 instance."
  type        = list(string)
}

variable "key_name" {
  description = "Optional key pair name."
  type        = string
  default     = null
}

variable "root_volume_size" {
  description = "Root volume size in GiB."
  type        = number
  default     = 20
}
