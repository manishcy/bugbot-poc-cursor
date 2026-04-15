terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  common_tags = merge(var.tags, { module = "ecs" })

  cluster_name = coalesce(var.cluster_name, "${var.name}-cluster")
  service_name = coalesce(var.service_name, "${var.name}-service")
  task_family  = coalesce(var.task_family, "${var.name}-task")

  task_execution_role_arn = var.execution_role_arn != null ? var.execution_role_arn : aws_iam_role.task_execution[0].arn
  task_role_arn           = var.task_role_arn != null ? var.task_role_arn : aws_iam_role.task[0].arn

  container_environment = [
    for key, value in var.environment :
    {
      name  = key
      value = value
    }
  ]

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = local.container_environment
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

data "aws_region" "current" {}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_execution" {
  count = var.execution_role_arn == null ? 1 : 0

  name               = "${var.name}-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
  tags               = merge(local.common_tags, { Name = "${var.name}-task-execution-role" })
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  count = var.execution_role_arn == null ? 1 : 0

  role       = aws_iam_role.task_execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
  count = var.task_role_arn == null ? 1 : 0

  name               = "${var.name}-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
  tags               = merge(local.common_tags, { Name = "${var.name}-task-role" })
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.name}"
  retention_in_days = var.log_retention_in_days

  tags = merge(local.common_tags, { Name = "/ecs/${var.name}" })
}

resource "aws_ecs_cluster" "this" {
  name = local.cluster_name

  setting {
    name  = "containerInsights"
    value = var.container_insights_enabled ? "enabled" : "disabled"
  }

  tags = merge(local.common_tags, { Name = local.cluster_name })
}

resource "aws_ecs_task_definition" "this" {
  family                   = local.task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.cpu)
  memory                   = tostring(var.memory)
  execution_role_arn       = local.task_execution_role_arn
  task_role_arn            = local.task_role_arn
  container_definitions    = local.container_definitions

  tags = merge(local.common_tags, { Name = local.task_family })

  depends_on = [aws_iam_role_policy_attachment.task_execution]
}

resource "aws_ecs_service" "this" {
  name                   = local.service_name
  cluster                = aws_ecs_cluster.this.id
  task_definition        = aws_ecs_task_definition.this.arn
  desired_count          = var.desired_count
  launch_type            = "FARGATE"
  platform_version       = var.platform_version
  enable_execute_command = var.enable_execute_command

  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  enable_ecs_managed_tags            = true
  propagate_tags                     = "SERVICE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = var.assign_public_ip
  }

  tags = merge(local.common_tags, { Name = local.service_name })

  depends_on = [aws_cloudwatch_log_group.this]
}
