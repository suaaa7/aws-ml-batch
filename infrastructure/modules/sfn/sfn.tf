variable "sfn_role_arn" {}
variable "lambda_arn" {}
variable "lambda_arn2" {}
variable "cluster_arn" {}
variable "task_def_arn" {}
variable "subnet" {}
variable "security_group" {}

resource "aws_sfn_state_machine" "sfn" {
  name     = "sfn"
  role_arn = var.sfn_role_arn

  definition = data.template_file.sfn.rendered
}

data "template_file" "sfn" {
  template = file("${path.module}/step_functions.json")

  vars = {
    lambda_arn     = var.lambda_arn
    lambda_arn2    = var.lambda_arn2
    task_def_arn   = var.task_def_arn
    cluster_arn    = var.cluster_arn
    subnet         = var.subnet
    security_group = var.security_group
  }
}

output "sfn_arn" {
  value = aws_sfn_state_machine.sfn.id
}
