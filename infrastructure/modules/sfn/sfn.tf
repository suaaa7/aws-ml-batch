variable "sfn_role_arn" {}
variable "lambda_arn" {}
variable "lambda_arn2" {}

resource "aws_sfn_state_machine" "sfn" {
  name     = "sfn"
  role_arn = var.sfn_role_arn

  definition = data.template_file.sfn.rendered
}

data "template_file" "sfn" {
  template = file("${path.module}/step_functions.json")

  vars = {
    lambda_arn  = var.lambda_arn
    lambda_arn2 = var.lambda_arn2
  }
}

output "sfn_arn" {
  value = aws_sfn_state_machine.sfn.id
}
