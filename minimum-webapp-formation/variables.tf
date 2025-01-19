variable "project_name" {
  description = "Project name to be used for resource naming"
  type        = string
  default     = "myapp"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "additional_tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}

variable "db_admin_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}