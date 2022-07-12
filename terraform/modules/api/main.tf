locals {
  team        = "infra"
  service     = "repo-registrar"
  api_name    = "${local.service}-api"
  bucket_name = "jff-global-lambda-deployments"
}

module "base_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = local.team
  name        = local.service
  stage       = var.stage
  environment = var.environment

  label_order = ["namespace", "stage", "name"]
}

module "lambda_api" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = ["api"]

  context    = module.base_label.context
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

  context = module.lambda_api.context
}

module "alb" {
  source  = "cloudposse/alb/aws"
  version = "1.4.0"

  http_ingress_cidr_blocks  = ["0.0.0.0/0"]
  #http_redirect             = true
  #https_enabled             = true
  #https_ingress_cidr_blocks = ["0.0.0.0/0"]
  target_group_target_type  = "lambda"
  subnet_ids                = var.subnet_ids
  vpc_id                    = var.vpc_id

  context = module.base_label.context
}

resource "aws_lambda_permission" "this" {
  statement_id  = "AllowExecutionFromLB"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.arn
  prinicipal    = "elasticloadbalancing.amazonaws.com"
  source_arn    = module.alb.default_target_group_arn
}

resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = module.alb.default_target_group_arn
  target_id        = module.lambda.arn
}
