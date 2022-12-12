data "aws_vpc" "vpc" {
  count = var.vpc_id != null ? 1 : 0

  id = var.vpc_id
}

resource "aws_security_group" "lambda" {
  count = var.vpc_id != null ? 1 : 0

  name        = var.function_name
  description = "Security group for the ${var.function_name} lambda"
  vpc_id      = var.vpc_id
}
