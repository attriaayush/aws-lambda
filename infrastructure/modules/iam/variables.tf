variable stage {
  description = "The stage/environment to deploy to."
}

variable "lambda_role_name" {
  description = "Name of a custom Lambda role to override the default Serverless one. The custom role should provide at least the same level of access as the default. If not specified, the role name defaults to `tf-SERVICE_NAME-STAGE-lambda-execution`."
  default     = ""
}

variable "service_name" {
  description = "Name of service / application"
}

variable "iam_partition" {
  description = "The IAM partition restriction for permissions (defaults to 'any partition')."
  default     = "*"
}

variable "iam_region" {
  description = "The IAM region restriction for permissions (defaults to 'any region')."
  default     = "*"
}

variable "iam_stage" {
  description = "The IAM stage restriction for permissions. Wildcarding stage is useful for dynamic environment creation."
  default     = ""
}

variable "region" {
  description = "The deploy target region in AWS. Defaults to: current inferred region"
  default     = ""
}

variable "tf_service_name" {
  description = "The unique name of service for Terraform resources. Defaults to: `tf-SERVICE_NAME`."
  default     = ""
}

variable "sls_service_name" {
  description = "The service name from Serverless configuration. Defaults to: `sls-SERVICE_NAME`."
  default     = ""
}

variable "iam_account_id" {
  description = "The AWS account ID to limit to in IAM. Defaults to: current inferred account id. Could be wildcarded."
  default     = ""
}

variable "role_developer_name" {
  description = "Developer role name"
  default     = "developer"
}

variable "opt_disable_groups" {
  description = "Do not create groups, only their policies"
  default     = false
}

variable "opt_many_lambdas" {
  description = "Allow all groups (incl developer, ci) to create and delete Lambdas"
  default     = false
}

data "aws_caller_identity" "current" {}
