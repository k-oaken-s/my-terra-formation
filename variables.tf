variable "region" {
    type = string
}

variable "aws_account_id" {
    type = string
}

variable "db_admin_username" {
    description = "Administrator username for the RDS instance"
    type        = string
}

variable "db_admin_password" {
    description = "Administrator password for the RDS instance"
    type        = string
    sensitive   = true
}

variable "app_username" {
    description = "Application username for the database"
    type        = string
}

variable "app_password" {
    description = "Application password for the database"
    type        = string
    sensitive   = true
}