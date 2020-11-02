provider aws {
  region = "us-west-2"
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
