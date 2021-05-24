provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

# Create VPC
resource "aws_vpc" "fargate" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Create Internet Gateway for VPC
resource "aws_internet_gateway" "ig" {
  vpc_id     = aws_vpc.fargate.id
  depends_on = [aws_vpc.fargate]
}

# Create Route Table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.fargate.id
  depends_on = [
    aws_vpc.fargate,
    aws_internet_gateway.ig
  ]
}

# Create Inernet Gatewat route for Route Table
resource "aws_route" "route" {
  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
  depends_on = [
    aws_vpc.fargate,
    aws_internet_gateway.ig,
    aws_route_table.rt
  ]
}

# Create public subnet insice VPC
resource "aws_subnet" "pub" {
  vpc_id                  = aws_vpc.fargate.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.aws_availability_zone
  depends_on              = [aws_vpc.fargate]
}

# Associate subnet with route table
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.pub.id
  route_table_id = aws_route_table.rt.id
  depends_on = [
    aws_subnet.pub,
    aws_route_table.rt
  ]
}

# Create Security Group
resource "aws_security_group" "sg" {
  vpc_id      = aws_vpc.fargate.id
  name        = "Fargate-SG"
  description = "Fargate Security Group"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic on port 80"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPs traffic on port 433"
    protocol    = "tcp"
    from_port   = 433
    to_port     = 433
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow All outgoint traffic for all ports"
    protocol    = "all"
    from_port   = -1
    to_port     = -1
  }

  depends_on = [aws_vpc.fargate]
}

# Create CloudWatch Log Group for Opencart
resource "aws_cloudwatch_log_group" "lg_opencart" {
  name              = var.opencart_awslogs_group
  retention_in_days = 0
}

# Create CloudWatch Log Group for MyMySQL
resource "aws_cloudwatch_log_group" "lg_mymysql" {
  name = var.mymysql_awslogs_group
}

# Create ECS Cluster
resource "aws_ecs_cluster" "fg_cluster" {
  name = "Cluster-TF"
}

# Create task execution role
resource "aws_iam_role" "exec_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = file(var.assume_role_policy_fn)

  inline_policy {
    name = "ecsTaskExecutionRolePolicy"

    policy = file(var.role_policy_fn)
  }
}

# Create new task definition for ECS Cluster
resource "aws_ecs_task_definition" "fg_task" {
  family                   = "opencart"
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = aws_ecs_cluster.fg_cluster.capacity_providers
  task_role_arn            = aws_iam_role.exec_role.arn
  execution_role_arn       = aws_iam_role.exec_role.arn
  container_definitions = templatefile(var.container_definition_fn, {
    region     = var.aws_region,
    account_id = local.account_id
    oc_lg      = var.opencart_awslogs_group,
    ms_lg      = var.mymysql_awslogs_group
  })
  tags = {
    "created_by" = "terraform"
  }
}

# Create ECS Service
resource "aws_ecs_service" "service" {
  name                               = "Service-TF"
  cluster                            = "Cluster-TF"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  deployment_controller {
    type = "ECS"
  }
  desired_count = 1
  launch_type   = "FARGATE"
  network_configuration {
    assign_public_ip = true
    subnets          = [aws_subnet.pub.id]
    security_groups  = [aws_security_group.sg.id]
  }
  scheduling_strategy = "REPLICA"
  task_definition     = aws_ecs_task_definition.fg_task.id
  depends_on = [
    aws_ecs_task_definition.fg_task,
    aws_ecs_cluster.fg_cluster,
    aws_subnet.pub,
    aws_security_group.sg,
    aws_cloudwatch_log_group.lg_opencart,
    aws_cloudwatch_log_group.lg_mymysql
  ]
}
