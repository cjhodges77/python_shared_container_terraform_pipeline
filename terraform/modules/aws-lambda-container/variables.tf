variable "account_engineer_boundaries" {
  type = map(string)
}

variable "environment_variables" {
  description = "Environment variables to pass to the lambda function"
  type        = map(string)
}

variable "function_name" {
  description = "The lambda function's name"
  type        = string
}

variable "function_version_override" {
  description = "The function version to override the latest alias to"
  default     = null
  type        = string
}

variable "image_uri" {
  description = "The full image URI to the image that should be published"
  type        = string
}

variable "lambda_git_repo" {
  description = "URL for the GitHub repository"
  type        = string
}

variable "log_subscription_filter_destination_arn" {
  description = "The Kibana log subscription destination ARN"
  type        = string
}

variable "memory_size" {
  default     = 256
  description = "The amount of memory to allocate to the lambda function"
  type        = number
}

variable "timeout" {
  default     = 900
  description = "How long the lambda is allowed to run before timing out"
  type        = number
}

variable "vpc_id" {
  default     = null
  description = "The VPC id the lambda should use if it needs to be in a VPC"
  type        = string
}

variable "vpc_subnet_ids" {
  default     = []
  description = "The list of subnet ids the lambda should use if it needs to be in a VPC"
  type        = list(string)
}
