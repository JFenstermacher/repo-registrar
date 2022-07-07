module "s3_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "2.0.3"
  
  acl                = "private"
  versioning_enabled = false

  namespace   = "jff"
  environment = "global"
  name        = "lambda-deployments"
}
