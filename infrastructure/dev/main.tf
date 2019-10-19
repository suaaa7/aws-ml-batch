terraform {
  required_version = "0.12.6"
}

provider "aws" {
  version = "2.23.0"
  region  = "ap-northeast-1"
}

# IAM
module "ecs_tasks_role" {
  source = "../modules/iam"

  name       = "ecs-task-execution"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy.ecs_tasks_role_policy.policy
}

data "aws_iam_policy" "ecs_tasks_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

module "lambda_role" {
  source = "../modules/iam"

  name       = "lambda"
  identifier = "lambda.amazonaws.com"
  policy     = data.aws_iam_policy.lambda_role_policy.policy
}

data "aws_iam_policy" "lambda_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
}

module "sfn_role" {
  source = "../modules/iam_for_sfn"

  name               = "sfn"
  ecs_tasks_role_arn = module.ecs_tasks_role.iam_role_arn
}

# Network
module "network" {
  source = "../modules/network"

  project = var.project
}

# Security
module "security" {
  source = "../modules/security"

  project = var.project
  vpc     = module.network.vpc
}

# S3
module "s3" {
  source = "../modules/s3"

  bucket_name        = var.bucket_name
  ecs_tasks_role_arn = module.ecs_tasks_role.iam_role_arn
  lambda_role_arn    = module.lambda_role.iam_role_arn
  sfn_role_arn       = module.sfn_role.iam_role_arn
}

# ECR
module "ecr" {
  source = "../modules/ecr"

  ecr_repository = var.ecr_repository
}

# Fargate
module "fargate" {
  source = "../modules/fargate"

  project                           = var.project
  ecs_tasks_role_arn                = module.ecs_tasks_role.iam_role_arn
  repository_url                    = module.ecr.repository_url
  image_tag                         = var.image_tag
  cloudwatch_log_group_fargate_name = module.cloudwatch.cloudwatch_log_group_fargate_name
}

# SFN
module "sfn" {
  source = "../modules/sfn"

  sfn_role_arn   = module.sfn_role.iam_role_arn
  lambda_arn     = var.apex_function_notify-slack
  lambda_arn2    = var.apex_function_check-result
  cluster_arn    = module.fargate.cluster_arn
  task_def_arn   = module.fargate.task_def_arn
  subnet         = module.network.private_subnet
  security_group = module.security.security_group
}

# CloudWatch
module "cloudwatch" {
  source = "../modules/cloudwatch"

  project      = var.project
  sfn_role_arn = module.sfn_role.iam_role_arn
  sfn_arn      = module.sfn.sfn_arn
}
