resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = 30

  tags = {
    component = var.function_name
  }
}

resource "aws_cloudwatch_log_subscription_filter" "kibana" {
  name            = "${var.function_name}-kibana"
  log_group_name  = aws_cloudwatch_log_group.lambda.name
  filter_pattern  = "-RequestId"
  destination_arn = var.log_subscription_filter_destination_arn
}
