terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.4"
    }
    node-lambda-packager = {
      source  = "jSherz/node-lambda-packager"
      version = "~> 1.0"
    }
  }
}
