# variables

variable "aws_region" {}
variable "project" {}
variable "ecr_repository" {}
variable "image_tag" {}
variable "bucket_name" {}

## apex
variable "apex_function_notify_slack" {}

# output

output "lambda_role_arn" {
  value = module.lambda_role.iam_role_arn
}
