variable "project" {}
variable "sfn_role_arn" {}
variable "sfn_arn" {}

# CloudWatch Log

### Fargate
resource "aws_cloudwatch_log_group" "for_fargate" {
  name              = "/fargate/${var.project}"
  retention_in_days = 30
}

### SFN
resource "aws_cloudwatch_log_group" "for_sfn" {
  name              = "/sfn/${var.project}"
  retention_in_days = 30
}

# CloudWatch Event

### Fargate

### SFN
resource "aws_cloudwatch_event_rule" "sfn" {
  name                = "every_10_minute"
  schedule_expression = "cron(*/10 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "sfn" {
  rule      = aws_cloudwatch_event_rule.sfn.id
  target_id = "sfn"
  role_arn  = var.sfn_role_arn
  arn       = var.sfn_arn
}

output "cloudwatch_log_group_fargate_name" {
  value = aws_cloudwatch_log_group.for_fargate.name
}
