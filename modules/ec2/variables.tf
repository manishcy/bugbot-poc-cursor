variable "ami_id" {
  description = "AMI ID to use for the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "instance_name" {
  description = "Name tag value for the EC2 instance."
  type        = string
  default     = "ec2-instance"
}

variable "subnet_id" {
  description = "Subnet ID in which to launch the instance."
  type        = string
  default     = null
}

variable "availability_zone" {
  description = "Availability zone for the instance. Keep null to let AWS choose."
  type        = string
  default     = null
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address to the instance."
  type        = bool
  default     = null
}

variable "user_data" {
  description = "User data script passed to the instance."
  type        = string
  default     = null
}

variable "create_key_pair" {
  description = "Whether to create an AWS key pair in this module."
  type        = bool
  default     = false
}

variable "key_name" {
  description = "Key pair name for the instance. Required when create_key_pair is true."
  type        = string
  default     = null

  validation {
    condition     = !var.create_key_pair || (var.key_name != null && trim(var.key_name) != "")
    error_message = "key_name must be provided when create_key_pair is true."
  }
}

variable "public_key" {
  description = "Public key material for key pair creation. Required when create_key_pair is true."
  type        = string
  default     = null

  validation {
    condition     = !var.create_key_pair || (var.public_key != null && trim(var.public_key) != "")
    error_message = "public_key must be provided when create_key_pair is true."
  }

  validation {
    condition     = var.create_key_pair || var.public_key == null
    error_message = "public_key can only be set when create_key_pair is true."
  }
}

variable "create_security_group" {
  description = "Whether to create a dedicated security group in this module."
  type        = bool
  default     = true
}

variable "security_group_name" {
  description = "Name of the security group created by this module."
  type        = string
  default     = "ec2-instance-sg"
}

variable "security_group_description" {
  description = "Description of the security group created by this module."
  type        = string
  default     = "Security group managed by Terraform module ec2"
}

variable "vpc_id" {
  description = "VPC ID where the managed security group is created."
  type        = string
  default     = null

  validation {
    condition     = !var.create_security_group || (var.vpc_id != null && trim(var.vpc_id) != "")
    error_message = "vpc_id must be provided when create_security_group is true."
  }
}

variable "security_group_ids" {
  description = "Existing security group IDs to attach to the instance."
  type        = list(string)
  default     = []
}

variable "security_group_ingress_rules" {
  description = "Ingress rules applied to the created security group."
  type = list(object({
    description      = optional(string, null)
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = optional(list(string), [])
    ipv6_cidr_blocks = optional(list(string), [])
    prefix_list_ids  = optional(list(string), [])
    security_groups  = optional(list(string), [])
    self             = optional(bool, false)
  }))
  default = []

  validation {
    condition     = var.create_security_group || length(var.security_group_ingress_rules) == 0
    error_message = "security_group_ingress_rules can only be set when create_security_group is true."
  }
}

variable "security_group_egress_rules" {
  description = "Egress rules applied to the created security group."
  type = list(object({
    description      = optional(string, null)
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = optional(list(string), [])
    ipv6_cidr_blocks = optional(list(string), [])
    prefix_list_ids  = optional(list(string), [])
    security_groups  = optional(list(string), [])
    self             = optional(bool, false)
  }))
  default = [
    {
      description      = "Allow all outbound traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "instance_tags" {
  description = "Additional tags applied only to the EC2 instance."
  type        = map(string)
  default     = {}
}

variable "security_group_tags" {
  description = "Additional tags applied only to the security group."
  type        = map(string)
  default     = {}
}

variable "key_pair_tags" {
  description = "Additional tags applied only to the key pair."
  type        = map(string)
  default     = {}
}
