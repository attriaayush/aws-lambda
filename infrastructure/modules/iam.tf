module serverless {
  source = "FormidableLabs/serverless/aws"

  region = "eu-west-2"
  service_name = "myapi"
  stage = ${var.stage}

  iam_region        = `*`
  iam_partition     = `*`
  iam_account_id    = `AWS_CALLER account`
  tf_service_name   = `tf-SERVICE_NAME`
  sls_service_name  = `sls-SERVICE_NAME`
}
