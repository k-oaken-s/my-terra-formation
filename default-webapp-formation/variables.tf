variable "project_name" {
  description = "Project name to be used for resource naming"
  type        = string
  default     = "rankifyhub"
}

variable "environment" {
  description = "Environment name (e.g. prod, dev, staging)"
  type        = string
  default     = "prod"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "db_admin_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "db_admin_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

variable "app_username" {
  description = "Application database username"
  type        = string
  sensitive   = true
}

variable "app_password" {
  description = "Application database password"
  type        = string
  sensitive   = true
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "additional_tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}

# Auto Scaling設定
variable "ecs_min_capacity" {
  description = "Minimum number of ECS tasks"
  type        = number
  default     = 2
}

variable "ecs_max_capacity" {
  description = "Maximum number of ECS tasks"
  type        = number
  default     = 4
}

variable "ecs_target_capacity" {
  description = "Target CPU utilization (%)"
  type        = number
  default     = 80
}

# CloudWatchログ設定
variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

# RDS設定
variable "rds_backup_retention_period" {
  description = "Number of days to retain RDS backups"
  type        = number
  default     = 7
}

variable "rds_backup_window" {
  description = "The daily time range during which automated backups are created"
  type        = string
  default     = "03:00-04:00"
}

variable "rds_maintenance_window" {
  description = "The window to perform RDS maintenance"
  type        = string
  default     = "Mon:04:00-Mon:05:00"
}

# コンテナ設定
variable "container_cpu" {
  description = "Amount of CPU to allocate to each container"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Amount of memory to allocate to each container"
  type        = number
  default     = 512
}

variable "container_port" {
  description = "Port on which the container will listen"
  type        = number
  default     = 8080
}

# データベース設定
variable "db_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
  default     = 20
}

variable "db_engine" {
  description = "The database engine to use"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "The engine version to use"
  type        = string
  default     = "8.0"
}

variable "db_port" {
  description = "The port on which the DB accepts connections"
  type        = number
  default     = 3306
}