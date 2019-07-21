variable "aws_region" {}
variable "project" {}
variable "ecs_tasks_role_arn" {}
variable "ecs_events_role_arn" {}
variable "private_subnets" {}
variable "fargate_security_group" {}
variable "repository_url" {}
variable "image_tag" {}

# CloudWatch Log
resource "aws_cloudwatch_log_group" "for_ecs_scheduled_tasks" {
  name = "/ecs-scheduled-tasks/${var.project}"
  retention_in_days = 30
}

# CloudWatch Event
resource "aws_cloudwatch_event_rule" "fargate_batch" {
  name = var.project
  description = "fargate"
  schedule_expression = "cron(*/5 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "fargate_batch" {
  target_id = var.project
  rule = aws_cloudwatch_event_rule.fargate_batch.name
  role_arn = var.ecs_events_role_arn
  arn = aws_ecs_cluster.cluster.arn

  ecs_target {
    launch_type = "FARGATE"
    task_count = 1
    platform_version = "1.3.0"
    task_definition_arn = aws_ecs_task_definition.task_def.arn

    network_configuration {
      subnets = flatten([var.private_subnets])
      security_groups = [var.fargate_security_group]
      assign_public_ip = "false"
    }
  }
}

# Cluster
resource "aws_ecs_cluster" "cluster" {
  name = "fargate-cluster"
}

# Task Definition
resource "aws_ecs_task_definition" "task_def" {
  family = "fargate"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = "256"
  memory = "512"
  task_role_arn = var.ecs_tasks_role_arn
  execution_role_arn = var.ecs_tasks_role_arn
  container_definitions = data.template_file.task_def.rendered
}

data "template_file" "task_def" {
  template = file("json/task_definition.json")

  vars = {
    repository_url = var.repository_url
    image_tag = var.image_tag
    aws_region = var.aws_region
    cloudwatch_log_group = aws_cloudwatch_log_group.for_ecs_scheduled_tasks.name
  }
}
