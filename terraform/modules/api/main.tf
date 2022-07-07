locals {
  team        = "infra"
  service     = "repo-registrar"
  api_name    = "${local.service}-api"
  bucket_name = "jff-global-lambda-deployments"
}

module "base_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace = local.team
  name      = local.service
  stage     = var.stage
}

module "lambda_api" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = ["api"]
  context = module.base_label.context
}

module "lambda" {
  source  = "cloudposse/lambda-function/aws"
  version = "0.4.1"

  function_name = module.lambda_api.id
  handler       = module.lambda_api.id
  runtime       = "go1.x"
  s3_bucket     = local.bucket_name
  s3_key        = "${local.team}/${local.service}/${local.api_name}/${var.git_sha}.zip"
  publish       = true
}
