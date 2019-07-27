variable "name" {}
variable "policy_arn" {}
variable "identifier" {}

resource "aws_iam_role" "lambda" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [var.identifier]
    }
  }
}

resource "aws_iam_policy_attachment" "lambda" {
  name       = var.name
  roles      = [aws_iam_role.lambda.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

output "iam_role_arn" {
  value = aws_iam_role.lambda.arn
}

output "iam_role_name" {
  value = aws_iam_role.lambda.name
}
