terraform {
  backend "s3" {
    bucket = "jfenstermacher-terraform"
    key = "repo-registrar"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.21.0"
    }
  }
}
