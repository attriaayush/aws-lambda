provider aws {
  region = "us-west-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

terraform {
  backend "s3" {
    encrypt = true
    bucket  = "terraform-state-production-38a4082e-1d56"
    key     = "terraform.tfstate"
    region  = "us-west-2"
  }
}

module serverless {
  source        = "../modules/iam"

  service_name  = "hello-world"
  stage         = var.stage
}

