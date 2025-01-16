# General
project_name = "rankifyhub"
environment  = "prod"
region       = "ap-northeast-1"

# Networking
availability_zones = [
  "ap-northeast-1a",
  "ap-northeast-1c"
]
vpc_cidr = "10.0.0.0/16"

# AWS Account
aws_account_id = "123456789012"

# Tags
additional_tags = {
  ManagedBy   = "terraform"
  Owner       = "platform-team"
  Repository  = "github.com/org/repo"
  Environment = "prod"
}

# Auto Scaling
ecs_min_capacity     = 2
ecs_max_capacity     = 4
ecs_target_capacity  = 80

# CloudWatch
log_retention_days = 30

# Backup
rds_backup_retention_period = 7
rds_backup_window          = "03:00-04:00"
rds_maintenance_window     = "Mon:04:00-Mon:05:00"

# Container
container_cpu    = 256
container_memory = 512
container_port   = 8080

# Database
db_instance_class    = "db.t3.micro"
db_allocated_storage = 20
db_engine           = "mysql"
db_engine_version   = "8.0"
db_port             = 3306