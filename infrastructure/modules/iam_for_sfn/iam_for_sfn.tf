variable "aws_region" {}
variable "name" {}
variable "ecs_tasks_role_arn" {}

resource "aws_iam_role" "sfn" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.sfn.json
}

data "aws_iam_policy_document" "sfn" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "states.amazonaws.com",
        "events.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy" "sfn" {
  name   = var.name
  role   = aws_iam_role.sfn.id
  policy = data.aws_iam_policy_document.sfn_for_cloudwatch.json
}

data "aws_iam_policy_document" "sfn_for_cloudwatch" {
  statement {
    effect = "Allow"
    actions = [
      "states:*",
      "lambda:InvokeFunction",
      "ecs:RunTask",
      "ecs:StopTask",
      "ecs:DescribeTasks",
      "events:PutTargets",
      "events:PutRule",
      "events:DescribeRule"
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [var.ecs_tasks_role_arn]
  }
}

output "iam_role_arn" {
  value = aws_iam_role.sfn.arn
}

output "iam_role_name" {
  value = aws_iam_role.sfn.name
}
