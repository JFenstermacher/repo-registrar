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
  default     = "vpc-a8f360d3"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs."

  default = [
    "subnet-223d070d", # us-east-1a
    "subnet-e40cc0ae", # us-east-1b
    "subnet-35a09868"  # us-east-1c
  ]
}
