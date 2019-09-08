variable "aws_region" {}
variable "project" {}
variable "ecs_tasks_role_arn" {}
variable "repository_url" {}
variable "image_tag" {}
variable "cloudwatch_log_group_fargate_name" {}

# Cluster
resource "aws_ecs_cluster" "cluster" {
  name = "fargate-cluster"
}

# Task Definition
resource "aws_ecs_task_definition" "task_def" {
  family                   = "fargate"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  task_role_arn            = var.ecs_tasks_role_arn
  execution_role_arn       = var.ecs_tasks_role_arn
  container_definitions    = data.template_file.task_def.rendered
}

data "template_file" "task_def" {
  template = file("${path.module}/task_definition.json")

  vars = {
    repository_url       = var.repository_url
    image_tag            = var.image_tag
    aws_region           = var.aws_region
    cloudwatch_log_group = var.cloudwatch_log_group_fargate_name
  }
}

output "cluster_arn" {
  value = aws_ecs_cluster.cluster.arn
}

output "task_def_arn" {
  value = aws_ecs_task_definition.task_def.arn
}
