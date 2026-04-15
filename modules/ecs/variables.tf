variable "name" {
  description = "Name prefix for ECS resources."
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster."
  type        = string
  default     = null
}

variable "service_name" {
  description = "Name of the ECS service."
  type        = string
  default     = null
}

variable "task_family" {
  description = "Family name for the ECS task definition."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "Subnets for ECS service ENIs."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups for ECS service ENIs."
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Assign public IP to ECS tasks."
  type        = bool
  default     = false
}

variable "container_name" {
  description = "Container name."
  type        = string
}

variable "container_image" {
  description = "Container image URI."
  type        = string
}

variable "container_port" {
  description = "Container port."
  type        = number
}

variable "cpu" {
  description = "Task CPU units."
  type        = number
  default     = 256
}

variable "memory" {
  description = "Task memory in MiB."
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of ECS tasks."
  type        = number
  default     = 1
}

variable "execution_role_arn" {
  description = "IAM role ARN for ECS task execution."
  type        = string
  default     = null
}

variable "task_role_arn" {
  description = "IAM role ARN for ECS task."
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment variables for the container."
  type        = map(string)
  default     = {}
}

variable "container_insights_enabled" {
  description = "Enable ECS container insights."
  type        = bool
  default     = true
}

variable "log_retention_in_days" {
  description = "CloudWatch log retention period."
  type        = number
  default     = 30
}

variable "platform_version" {
  description = "Fargate platform version."
  type        = string
  default     = "LATEST"
}

variable "enable_execute_command" {
  description = "Enable ECS Exec for tasks."
  type        = bool
  default     = false
}

variable "deployment_minimum_healthy_percent" {
  description = "Lower bound on healthy tasks during deployment."
  type        = number
  default     = 50
}

variable "deployment_maximum_percent" {
  description = "Upper bound on running tasks during deployment."
  type        = number
  default     = 200
}
