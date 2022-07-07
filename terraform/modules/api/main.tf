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

module "security_group" {
  source  = "cloudposse/security-group/aws"
  version = "1.0.1"

  allow_all_egress = true
  vpc_id           = var.vpc_id

  rules = [
    {
      key         = "HTTPS"
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTPS traffic"
    },
    {
      key         = "HTTP"
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP traffic"
    }
  ]
}
