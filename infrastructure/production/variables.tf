variable stage {
  description = "The stage/environment to deploy to."
  default     = "production" // potentially have prod, staging and development
}

variable aws_access_key {
  type        = string
  description = "AWS Access Key"
}

variable aws_secret_key {
  type        = string
  description = "AWS Secret Key"
}
