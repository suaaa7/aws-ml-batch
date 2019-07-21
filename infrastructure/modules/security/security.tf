variable "project" {}
variable "vpc" {}

resource "aws_security_group" "default" {
  name = var.project
  vpc_id = var.vpc

  tags = {
    Name = var.project
  }
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}

output "security_group" {
  value = aws_security_group.default.id
}
