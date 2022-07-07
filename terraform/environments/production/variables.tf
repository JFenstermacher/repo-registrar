variable "git_sha" {
  type        = string
  description = <<-EOT
    The git SHA of the lambda that should be deployed. Lambda contents are packaged and pushed base on git SHA.
    A new version of the lambda will be created, and CodeDeploy will handle the actual rolling over of the lambda.
    EOT
}
