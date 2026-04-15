variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Base name prefix for resource naming."
  type        = string
  default     = "platform"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "availability_zones" {
  description = "Availability Zones to deploy across."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "container_image" {
  description = "Container image to run in ECS."
  type        = string
  default     = "public.ecr.aws/nginx/nginx:stable"
}

variable "container_port" {
  description = "Container and service port."
  type        = number
  default     = 80
}

variable "allowed_app_ingress_cidrs" {
  description = "CIDRs allowed to access the ECS application port."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "desired_count" {
  description = "Desired number of ECS tasks."
  type        = number
  default     = 1
}

variable "task_cpu" {
  description = "ECS task CPU units."
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "ECS task memory in MiB."
  type        = number
  default     = 512
}

variable "ecs_execution_role_arn" {
  description = "Optional existing IAM role ARN for ECS task execution."
  type        = string
  default     = null
}

variable "ecs_task_role_arn" {
  description = "Optional existing IAM role ARN for ECS task."
  type        = string
  default     = null
}

variable "enable_execute_command" {
  description = "Enable ECS Exec on the service."
  type        = bool
  default     = true
}

variable "db_name" {
  description = "Initial PostgreSQL database name."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "PostgreSQL master username."
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "PostgreSQL master password."
  type        = string
  sensitive   = true
  default     = "ChangeMe123!"
}

variable "db_engine_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "16.3"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage in GiB."
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Maximum autoscaled storage in GiB."
  type        = number
  default     = 100
}

variable "db_multi_az" {
  description = "Whether to enable Multi-AZ deployment."
  type        = bool
  default     = false
}

variable "db_backup_retention_period" {
  description = "Backup retention in days."
  type        = number
  default     = 7
}

variable "db_deletion_protection" {
  description = "Enable deletion protection for the DB instance."
  type        = bool
  default     = true
}

variable "db_skip_final_snapshot" {
  description = "Skip final snapshot when destroying DB instance."
  type        = bool
  default     = false
}

variable "db_publicly_accessible" {
  description = "Whether RDS endpoint should be publicly accessible."
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default = {
    Environment = "example"
    ManagedBy   = "terraform"
  }
}
