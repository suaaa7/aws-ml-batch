# variables
variable "aws_region" {}
variable "project" {}
variable "ecr_repository" {}
variable "image_tag" {}
variable "bucket_name" {}

## apex
variable "apex_environment" {
  default = ""
}
variable "apex_function_role" {
  default = ""
}
variable "apex_function_arns" {
  default = ""
}
variable "apex_function_names" {
  default = ""
}
variable "apex_function_notify-slack" {
  default = ""
}
variable "apex_function_notify-slack_name" {
  default = ""
}
variable "apex_function_check-result" {
  default = ""
}
variable "apex_function_check-result_name" {
  default = ""
}

# output
output "lambda_function_role_id" {
  value = module.lambda_role.iam_role_arn
}
