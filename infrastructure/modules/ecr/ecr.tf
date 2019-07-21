variable "ecr_repository" {}

resource "aws_ecr_repository" "ecr" {
  name = var.ecr_repository
}

resource "aws_ecr_lifecycle_policy" "ecr" {
  repository = aws_ecr_repository.ecr.name

  policy = data.template_file.ecr.rendered
}

data "template_file" "ecr" {
  template = file("ecr_lifecycle_policy.json")
}

output "repository_url" {
  value = aws_ecr_repository.ecr.repository_url
}
