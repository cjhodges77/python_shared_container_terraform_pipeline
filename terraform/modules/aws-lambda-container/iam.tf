data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    principals {
      identifiers = [
        "lambda.amazonaws.com"
      ]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "lambda" {
  assume_role_policy   = data.aws_iam_policy_document.lambda_assume_role.json
  permissions_boundary = lookup(var.account_engineer_boundaries, data.aws_caller_identity.current.account_id, "")
  name_prefix          = var.function_name
}

data "aws_iam_policy_document" "lambda_logs" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    effect    = "Allow"
    resources = ["${aws_cloudwatch_log_group.lambda.arn}*"]
    sid       = "AllowWritingLogsToCloudWatch"
  }
}

resource "aws_iam_role_policy" "lambda_logs" {
  name   = "lambda-logs"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_logs.json
}

data "aws_iam_policy_document" "lambda_vpc" {
  statement {
    actions = [
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeInstances",
      "ec2:AttachNetworkInterface",
    ]
    effect = "Allow"
    resources = [
      "*",
    ]
    sid = "AllowLambdaToRunInVPC"
  }
}

resource "aws_iam_role_policy" "lambda_vpc" {
  count = var.vpc_id != null ? 1 : 0

  name   = "lambda-vpc"
  policy = data.aws_iam_policy_document.lambda_vpc.json
  role   = aws_iam_role.lambda.id
}
