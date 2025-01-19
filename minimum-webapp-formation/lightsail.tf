resource "aws_lightsail_container_service" "app" {
  name        = "${var.project_name}-service"
  power       = "nano"
  scale       = 1
  is_disabled = false

  tags = {
    Name = "${var.project_name}-container-service"
  }
}

resource "aws_lightsail_container_service_deployment_version" "app" {
  container {
    container_name = "app"
    image         = "${var.project_name}:latest"
    
    environment_variable {
      key   = "SPRING_PROFILES_ACTIVE"
      value = "prod"
    }

    ports {
      port_number = 8080
      protocol    = "HTTP"
    }
  }

  service_name = aws_lightsail_container_service.app.name
}

resource "aws_lightsail_database" "main" {
  relational_database_name = "${var.project_name}-db"
  availability_zone       = "${var.region}a"
  blueprint_id           = "mysql_8_0"
  bundle_id             = "micro_1_0"
  master_database_name  = var.project_name
  master_password      = var.db_admin_password
  master_username      = "dbadmin"
  
  backup_retention_enabled = true
  preferred_backup_window = "03:00-04:00"
  
  tags = {
    Name = "${var.project_name}-database"
  }
}