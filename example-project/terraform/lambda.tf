module "lambda" {
  source = "git::ssh://git@github.com/cjhodges77/python_shared_container_terraform_pipeline/terraform/modules/aws-lambda-container?depth=1"

  account_engineer_boundaries = var.account_engineer_boundaries
  environment_variables = {
    hello = "world"
  }
  function_name                           = var.component
  image_uri                               = "************.dkr.ecr.eu-west-2.amazonaws.com/aws-lambda-example-project:${var.image_tag}"
  lambda_git_repo                         = var.lambda_git_repo
  log_subscription_filter_destination_arn = var.log_subscription_filter_destination_arn
}
