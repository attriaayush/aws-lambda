locals {
  account_id               = data.aws_caller_identity.current.account_id
  stage                    = var.stage
  iam_partition            = "aws"
  iam_region               = var.iam_region
  sls_service_name         = var.sls_service_name != "" ? var.sls_service_name : "sls-${var.service_name}"
  tf_service_name          = var.tf_service_name != "" ? var.tf_service_name : "tf-${var.service_name}"
  iam_account_id           = var.iam_account_id != "" ? var.iam_account_id : data.aws_caller_identity.current.account_id
  iam_stage                = var.iam_stage != "" ? var.iam_stage : var.stage
  role_developer_name      = var.role_developer_name

  opt_many_lambdas         = var.opt_many_lambdas
  opt_disable_groups       = var.opt_disable_groups
  tf_group_name            = "${local.tf_service_name}-${local.stage}-${local.role_developer_name}"

  tags = {
    "Service" = var.service_name
    "Stage"   = var.stage
  }
}

locals {
  default_lambda_role_name = "tf-${var.service_name}-${var.stage}-lambda-execution"
  lambda_role_name         = var.lambda_role_name != "" ? var.lambda_role_name : local.default_lambda_role_name

  sls_cloudformation_arn   = "arn:${local.iam_partition}:cloudformation:${local.iam_region}:${local.iam_account_id}:stack/${local.sls_service_name}-${local.iam_stage}/*"
  sls_deploy_bucket_arn    = "arn:${local.iam_partition}:s3:::${local.sls_service_name}-*-serverless*-*"

  lambda_role_iam_arn      = "arn:${local.iam_partition}:iam::${local.iam_account_id}:role/${local.lambda_role_name}"

  sls_lambda_arn           = "arn:${local.iam_partition}:lambda:${local.iam_region}:${local.iam_account_id}:function:${local.sls_service_name}-${local.iam_stage}-*"
  sls_layer_arn            = "arn:${local.iam_partition}:lambda:${local.iam_region}:${local.iam_account_id}:layer:${local.sls_service_name}-${local.iam_stage}-*"
  sls_apigw_arn            = "arn:${local.iam_partition}:apigateway:${local.iam_region}::/restapis*"
  sls_apigw_tags_arn       = "arn:${local.iam_partition}:apigateway:${local.iam_region}::/tags*"
  sls_log_stream_arn       = "arn:${local.iam_partition}:logs:${local.iam_region}:${local.iam_account_id}:log-group:/aws/lambda/${local.sls_service_name}-${local.iam_stage}-*:log-stream:"
}

resource "aws_iam_user" "ci_developer" {
  name = "tf-ci-${var.stage}-developer"
  path = "/"

  tags = {
    "Service" = var.service_name
    "Stage"   = var.stage
  }
}


resource "aws_iam_policy" "developer" {
  name   = local.tf_group_name
  path   = "/"
  policy = data.aws_iam_policy_document.developer.json
}

resource "aws_iam_group" "developer" {
  count = local.opt_disable_groups ? 0 : 1
  name  = local.tf_group_name
}

resource "aws_iam_group_membership" "team" {
  count = local.opt_disable_groups ? 0 : 1
  name = "${local.tf_group_name}-membership"

  users = [
    aws_iam_user.ci_developer.name
  ]

  group = element(aws_iam_group.developer.*.name, count.index)
}

resource "aws_iam_group_policy_attachment" "developer_policy" {
  count      = local.opt_disable_groups ? 0 : 1
  group      = element(aws_iam_group.developer.*.name, count.index)
  policy_arn = aws_iam_policy.developer.arn
}

resource "aws_iam_role" "lambda" {
  count              = var.lambda_role_name != "" ? 0 : 1
  name               = "tf-${var.service_name}-${local.stage}-lambda-execution"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
  tags               = local.tags
}

resource "aws_iam_policy" "lambda" {
  name   = "tf-${var.service_name}-${local.stage}-lambda-execution"
  policy = data.aws_iam_policy_document.lambda.json
}

# Replicate the log permissions from the default Serverless role.
data "aws_iam_policy_document" "lambda" {
  statement {
    actions   = ["logs:CreateLogStream"]
    resources = ["arn:${local.iam_partition}:logs:${local.iam_region}:${local.iam_account_id}:log-group:/aws/lambda/${local.sls_service_name}-${local.iam_stage}*:*"]
  }

  statement {
    actions   = ["logs:PutLogEvents"]
    resources = ["arn:${local.iam_partition}:logs:${local.iam_region}:${local.iam_account_id}:log-group:/aws/lambda/${local.sls_service_name}-${local.iam_stage}*:*:*"]
  }
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = local.lambda_role_name
  policy_arn = aws_iam_policy.lambda.arn
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
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
      "cloudformation:CreateStack",
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
      "s3:CreateBucket"
    ]

    resources = [
      local.sls_deploy_bucket_arn,
    ]
  }

  statement {
    actions = [
      "iam:GetRole",
      "iam:PassRole",
      "iam:DeleteRolePolicy"
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
      "lambda:CreateFunction",
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
      "logs:CreateLogGroup"
    ]

    resources = [
      local.sls_log_stream_arn,
      "${local.sls_log_stream_arn}*",
    ]
  }
}
