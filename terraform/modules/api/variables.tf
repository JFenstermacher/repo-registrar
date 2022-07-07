variable "stage" {
  type        = string
  description = "ID element. Deployment stage, e.g 'prod', 'uat', 'staging'"
}

variable "environment" {
  type        = string
  description = "ID element. Most commonly synonymous with account"
}

variable "git_sha" {
  type        = string
  description = <<-EOT
    The git SHA of the lambda that should be deployed. Lambda contents are packaged and pushed base on git SHA.
    A new version of the lambda will be created, and CodeDeploy will handle the actual rolling over of the lambda.
    EOT
}

variable "vpc_id" {
  type        = string
  description = "VPC ID."
}
