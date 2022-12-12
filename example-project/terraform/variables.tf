variable "account_engineer_boundaries" {
  type = map(string)
}

variable "component" {
  description = "The name of the component"
  type        = string
}

variable "image_tag" {
  description = "The image tag to deploy"
  type        = string
}

variable "lambda_git_repo" {
  description = "URL for the GitHub repository"
  type        = string
}

variable "log_subscription_filter_destination_arn" {
  description = "The Kibana log subscription destination ARN"
}
