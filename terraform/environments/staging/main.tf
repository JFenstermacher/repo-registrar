module "app" {
  source = "../../modules/api"

  stage       = "staging"
  environment = "staging"
  git_sha     = var.git_sha
  vpc_id      = var.vpc_id
  subnet_ids  = var.subnet_ids
}
