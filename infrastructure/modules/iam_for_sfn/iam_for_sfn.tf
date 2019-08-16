variable "aws_region" {}

resource "aws_iam_role" "sfn" {
  name = "sfn"
  assume_role_policy = data.aws_iam_policy_document.sfn.json
}

data "aws_iam_policy_document" "sfn" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "states.${var.aws_region}.amazonaws.com",
        "events.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_policy_attachment" "sfn" {
  name = "AWSLambdaRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
  roles = [aws_iam_role.sfn.name]
}

resource "aws_iam_role_policy" "sfn" {
  name = "sfn"
  role = aws_iam_role.sfn.id
  policy = data.aws_iam_policy_document.sfn_for_cloudwatch.json
}

data "aws_iam_policy_document" "sfn_for_cloudwatch" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "states:StartExecution"
    ]
    resources = ["*"]
  }
}

output "iam_role_arn" {
  value = aws_iam_role.sfn.arn
}

output "iam_role_name" {
  value = aws_iam_role.sfn.name
}
