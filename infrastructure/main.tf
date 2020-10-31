provider aws {
  region = "us-west-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

terraform {
  backend "s3" {
    encrypt = true
    bucket = "terraform-state-bucket-myrunwebsite-123"
    key    = "terraform.tfstate"
    region = "us-west-2"
  }
}

resource "aws_s3_bucket" "terraform-state-bucket" {
    bucket = "terraform-state-bucket-myrunwebsite-123"
 
    versioning {
      enabled = true
    }
 
    lifecycle {
      prevent_destroy = true
    }
 
    tags = {
      Name = "S3 Terraform State Bucket"
    }      
}

module serverless {
  source = "FormidableLabs/serverless/aws"

  region = "eu-west-2"
  service_name = "myapi"
  stage = ${var.stage}

  # iam_region        = `*`
  # iam_partition     = `*`
  # iam_account_id    = `AWS_CALLER account`
  # tf_service_name   = `tf-SERVICE_NAME`
  # sls_service_name  = `sls-SERVICE_NAME`
}

