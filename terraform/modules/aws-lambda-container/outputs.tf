output "cloudwatch_log_group_arn" {
  value = aws_cloudwatch_log_group.lambda.arn
}

output "lambda_arn" {
  value = aws_lambda_alias.latest.arn
}

output "iam_role_id" {
  value = aws_iam_role.lambda.id
}

output "security_group_id" {
  value = var.vpc_id != null ? aws_security_group.lambda[0].id : null
}
