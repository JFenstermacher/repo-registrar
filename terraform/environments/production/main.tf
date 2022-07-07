module "app" {
  source = "../../modules/api"

  stage       = "production"
  environment = "prod"
  git_sha     = var.git_sha
}
