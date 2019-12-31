provider "aws" {
  version = "~> 2.6"
  region = "${var.aws_region}"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

resource "aws_ecr_repository" "demo_app" {
  name = "${var.env}-demo-app"
}
