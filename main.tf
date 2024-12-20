
terraform {
    required_version = ">= 1.0.0"
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.0"
        }
    }
}

provider "aws" {
    region = var.region
}

# VPC
resource "aws_vpc" "main" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = { Name = "main-vpc" }
}

# インターネットゲートウェイ
resource "aws_internet_gateway" "main_igw" {
    vpc_id = aws_vpc.main.id
    tags = { Name = "main-igw" }
}

# VPC Endpoints
resource "aws_vpc_endpoint" "s3" {
    vpc_id       = aws_vpc.main.id
    service_name = "com.amazonaws.${var.region}.s3"
}

resource "aws_vpc_endpoint" "ecr_dkr" {
    vpc_id            = aws_vpc.main.id
    service_name      = "com.amazonaws.${var.region}.ecr.dkr"
    vpc_endpoint_type = "Interface"
    subnet_ids = [aws_subnet.private_subnet.id]
    security_group_ids = [aws_security_group.ecs_task_sg.id]
}

resource "aws_vpc_endpoint" "ecr_api" {
    vpc_id            = aws_vpc.main.id
    service_name      = "com.amazonaws.${var.region}.ecr.api"
    vpc_endpoint_type = "Interface"
    subnet_ids = [aws_subnet.private_subnet.id]
    security_group_ids = [aws_security_group.ecs_task_sg.id]
}

# パブリックサブネット (ECRアクセス用)
resource "aws_subnet" "public_subnet" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "ap-northeast-1a"
    map_public_ip_on_launch = true
    tags = { Name = "public-subnet" }
}

# プライベートサブネット (ECSタスク、RDS用)
resource "aws_subnet" "private_subnet" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.2.0/24"
    availability_zone       = "ap-northeast-1a"
    map_public_ip_on_launch = false
    tags = { Name = "private-subnet" }
}

# パブリックルートテーブル
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main_igw.id
    }
    tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "public_rt_assoc" {
    subnet_id      = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}

# プライベートルートテーブル
resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.main.id
    tags = { Name = "private-rt" }
}

resource "aws_route_table_association" "private_rt_assoc" {
    subnet_id      = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private_rt.id
}

# ECSタスク用セキュリティグループ
resource "aws_security_group" "ecs_task_sg" {
    name        = "ecs-task-sg"
    description = "Security Group for ECS Tasks"
    vpc_id      = aws_vpc.main.id

    egress {
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = { Name = "ecs-task-sg" }
}

# RDS用SG
resource "aws_security_group" "rds_sg" {
    name        = "rds-sg"
    description = "Security Group for RDS"
    vpc_id      = aws_vpc.main.id
    tags = { Name = "rds-sg" }
}

# ECSタスク -> RDS アクセス許可
resource "aws_security_group_rule" "ecs_to_rds" {
    type                     = "ingress"
    from_port                = 3306
    to_port                  = 3306
    protocol                 = "tcp"
    security_group_id        = aws_security_group.rds_sg.id
    source_security_group_id = aws_security_group.ecs_task_sg.id
    description              = "Allow ECS tasks to access RDS"
}

# RDS用プライベートサブネット (複数AZ対応)
resource "aws_subnet" "db_subnet_1" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = "10.0.101.0/24"
    availability_zone = "ap-northeast-1a"
}

resource "aws_subnet" "db_subnet_2" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = "10.0.102.0/24"
    availability_zone = "ap-northeast-1c"
}

resource "aws_ecr_repository" "backend" {
    name         = "backend"
    force_delete = true
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
    name        = "main-db-subnet-group"
    description = "Database Subnet Group"
    subnet_ids = [
        aws_subnet.db_subnet_1.id,
        aws_subnet.db_subnet_2.id
    ]

    tags = {
        Name = "main-db-subnet-group"
    }
}

# RDSインスタンス (コスト最適化版)
resource "aws_db_instance" "main" {
    identifier           = "rankifyhub-database"
    engine               = "mysql"
    engine_version       = "8.0"
    instance_class = "db.t3.micro"
    allocated_storage    = 20
    username             = var.db_admin_username
    password             = var.db_admin_password
    db_subnet_group_name = aws_db_subnet_group.main.name
    vpc_security_group_ids = [aws_security_group.rds_sg.id]

    skip_final_snapshot = true
    publicly_accessible = false
    storage_encrypted   = true
    multi_az = false
    backup_retention_period = 0
    deletion_protection = false

    tags = {
        Name = "rankifyhub-database"
    }
}

# ECSクラスター
resource "aws_ecs_cluster" "rankify_hub_cluster" {
    name = "RankifyHubClusterNew"
}

# ECSサービス
resource "aws_ecs_service" "rankify_hub_service" {
    name            = "RankifyHubService"
    cluster         = aws_ecs_cluster.rankify_hub_cluster.id
    task_definition = aws_ecs_task_definition.rankify_hub.arn
    desired_count   = 1
    launch_type     = "FARGATE"

    network_configuration {
        subnets = [aws_subnet.private_subnet.id]
        security_groups = [aws_security_group.ecs_task_sg.id]
        assign_public_ip = false
    }

    depends_on = [aws_ecs_task_definition.rankify_hub]
}

# ECSタスク定義 (コスト最適化版)
resource "aws_ecs_task_definition" "rankify_hub" {
    family             = "RankifyHubTaskDef"
    network_mode       = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu = "256"
    memory = "512"
    execution_role_arn = aws_iam_role.ecs_task_execution.arn

    container_definitions = jsonencode([
        {
            name      = "backend"
            image     = "${var.aws_account_id}.dkr.ecr.${var.region}.amazonaws.com/backend:latest"
            essential = true
            memory    = 256
            cpu       = 128
            portMappings = [
                {
                    containerPort = 8080
                    protocol      = "tcp"
                }
            ]
            environment = [
                { name = "SPRING_PROFILES_ACTIVE", value = "prod" }
            ]
            secrets = [
                { name = "SPRING_DATASOURCE_URL", valueFrom = aws_secretsmanager_secret.db_url.arn }
            ]
            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    "awslogs-group"         = "/ecs/rankify-hub-task"
                    "awslogs-region"        = var.region
                    "awslogs-stream-prefix" = "ecs"
                }
            }
        }
    ])
}

# IAMロール
resource "aws_iam_role" "ecs_task_execution" {
    name = "ecsTaskExecutionRole"

    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow"
                Principal = { Service = "ecs-tasks.amazonaws.com" }
                Action = "sts:AssumeRole"
            }
        ]
    })
}

# Secrets Manager
resource "aws_secretsmanager_secret" "db_url" {
    name        = "/prod/spring.datasource.url"
    description = "Database URL for ECS"
}

resource "aws_secretsmanager_secret_version" "db_url_version" {
    secret_id     = aws_secretsmanager_secret.db_url.id
    secret_string = "jdbc:mysql://${aws_db_instance.main.address}:3306/rankifyhub-database"
}

# IAMロールポリシー
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
    role       = aws_iam_role.ecs_task_execution.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# CloudWatch ロググループ (ログ保持期間短縮)
resource "aws_cloudwatch_log_group" "ecs_log_group" {
    name              = "/ecs/rankify-hub-task"
    retention_in_days = 3
}

# SSMパラメータ
resource "aws_ssm_parameter" "spring_datasource_url" {
    name        = "/prod/spring.datasource.url"
    type        = "String"
    value       = "jdbc:mysql://${aws_db_instance.main.address}:3306/rankifyhub-database"
    description = "The JDBC URL for the database"
    tags = {
        Environment = "prod"
        Application = "spring"
    }
}

resource "aws_ssm_parameter" "app_username" {
    name        = "/prod/spring.datasource.username"
    type        = "String"
    value       = var.app_username
    description = "The username for the application"
    tags = {
        Environment = "prod"
        Application = "spring"
    }
}

resource "aws_ssm_parameter" "app_password" {
    name        = "/prod/spring.datasource.password"
    type        = "SecureString"
    value       = var.app_password
    description = "The password for the application"
    tags = {
        Environment = "prod"
        Application = "spring"
    }
}

# 出力
output "rds_endpoint" {
    value = aws_db_instance.main.address
}
