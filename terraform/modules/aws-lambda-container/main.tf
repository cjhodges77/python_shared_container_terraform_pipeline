resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.lambda.arn
  memory_size   = var.memory_size
  package_type  = "Image"
  image_uri     = var.image_uri
  publish       = true
  timeout       = var.timeout

  environment {
    variables = var.environment_variables
  }

  dynamic "vpc_config" {
    for_each = var.vpc_id != null ? [1] : []
    content {
      subnet_ids         = var.vpc_subnet_ids
      security_group_ids = [aws_security_group.lambda.id]
    }
  }

  tags = {
    Git_Repo = var.lambda_git_repo
  }
}

resource "aws_lambda_alias" "latest" {
  description      = var.function_version_override != null ? "The pinned version of the lambda" : "The latest version of the lambda"
  function_name    = aws_lambda_function.this.function_name
  function_version = coalesce(var.function_version_override, aws_lambda_function.this.version)
  name             = "latest"
}
