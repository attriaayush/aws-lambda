provider aws {
  region = "us-west-2"
}

resource "aws_s3_bucket" "terraform-state-bucket" {
    bucket = "terraform-state-production-38a4082e-1d56"
 
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
