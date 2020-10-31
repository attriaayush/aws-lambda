locals {
  account_id               = data.aws_caller_identity.current.account_id
  stage                    = var.stage
  iam_partition            = var.iam_partition
  iam_region               = var.iam_region
  sls_service_name         = var.sls_service_name != "" ? var.sls_service_name : "sls-${var.service_name}"
  tf_service_name          = var.tf_service_name != "" ? var.tf_service_name : "tf-${var.service_name}"
  iam_account_id           = var.iam_account_id != "" ? var.iam_account_id : data.aws_caller_identity.current.account_id
  iam_stage                = var.iam_stage != "" ? var.iam_stage : var.stage

  tags = {
    "Service" = var.service_name
    "Stage"   = var.stage
  }
}

locals {
  default_lambda_role_name = "tf-${var.service_name}-${var.stage}-lambda-execution"
  lambda_role_name         = var.lambda_role_name != "" ? var.lambda_role_name : local.default_lambda_role_name

  sls_cloudformation_arn  = "arn:${local.iam_partition}:cloudformation:${local.iam_region}:${local.iam_account_id}:stack/${local.sls_service_name}-${local.iam_stage}/*"
  sls_deploy_bucket_arn   = "arn:${local.iam_partition}:s3:::${local.sls_service_name}-*-serverless*-*"

  lambda_role_iam_arn     = "arn:${local.iam_partition}:iam::${local.iam_account_id}:role/${local.lambda_role_name}"

  sls_lambda_arn          = "arn:${local.iam_partition}:lambda:${local.iam_region}:${local.iam_account_id}:function:${local.sls_service_name}-${local.iam_stage}-*"
  sls_layer_arn           = "arn:${local.iam_partition}:lambda:${local.iam_region}:${local.iam_account_id}:layer:${local.sls_service_name}-${local.iam_stage}-*"
  sls_apigw_arn           = "arn:${local.iam_partition}:apigateway:${local.iam_region}::/restapis*"
  sls_apigw_tags_arn      = "arn:${local.iam_partition}:apigateway:${local.iam_region}::/tags*"
  sls_log_stream_arn      = "arn:${local.iam_partition}:logs:${local.iam_region}:${local.iam_account_id}:log-group:/aws/lambda/${local.sls_service_name}-${local.iam_stage}-*:log-stream:"

}


resource "aws_iam_policy" "developer" {
  name   = "developer-group"
  path   = "/"
  policy = data.aws_iam_policy_document.developer.json
}

data "aws_iam_policy_document" "developer" {
  statement {
    actions = [
      "cloudformation:ValidateTemplate",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "cloudformation:DescribeStackEvents",
      "cloudformation:DescribeStackResource",
      "cloudformation:DescribeStackResources",
      "cloudformation:ListChangeSets",
      "cloudformation:ListStackResources",
      "cloudformation:Get*",
      "cloudformation:UpdateStack",
      "cloudformation:DescribeStacks",
    ]

    resources = [
      local.sls_cloudformation_arn,
    ]
  }


  statement {
    actions = [
      "s3:ListBucketVersions",
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject",
    ]

    resources = [
      local.sls_deploy_bucket_arn,
    ]
  }

  statement {
    actions = [
      "iam:PassRole",
      "iam:GetRole",
    ]

    resources = [
      local.lambda_role_iam_arn,
    ]
  }


  statement {
    actions = [
      "lambda:GetAlias",
      "lambda:GetFunction",
      "lambda:GetFunctionConfiguration",
      "lambda:GetPolicy",
      "lambda:ListAliases",
      "lambda:ListVersionsByFunction",
      "lambda:AddPermission",
      "lambda:CreateAlias",
      "lambda:InvokeFunction",
      "lambda:PublishVersion",
      "lambda:RemovePermission",
      "lambda:Update*",
    ]

    resources = [
      local.sls_lambda_arn,
    ]
  }

  statement {
    actions = [
      "lambda:GetLayerVersion",
      "lambda:PublishLayerVersion",
      "lambda:DeleteLayerVersion",
    ]

    resources = [
      local.sls_layer_arn,
    ]
  }

  statement {
    actions = [
      "apigateway:GET",
      "apigateway:PATCH",
      "apigateway:POST",
      "apigateway:PUT",
      "apigateway:DELETE",
      "apigateway:UpdateRestApiPolicy",
    ]

    resources = [
      local.sls_apigw_arn,
      local.sls_apigw_tags_arn,
    ]
  }

  statement {
    actions = [
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups",
      "logs:FilterLogEvents",
      "logs:GetLogEvents",
    ]

    resources = [
      local.sls_log_stream_arn,
      "${local.sls_log_stream_arn}*",
    ]
  }
}
