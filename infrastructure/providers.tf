provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      "${var.company_identifier}:workload:project"   = "git@github.com:jSherz/right-sizing-lambda-functions.git"
      "${var.company_identifier}:workload:name"      = "right-sizing-lambda-functions"
      "${var.company_identifier}:workload:ref"       = var.ref
      "${var.company_identifier}:devops:environment" = terraform.workspace
    }
  }
}
