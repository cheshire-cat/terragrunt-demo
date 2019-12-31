provider "aws" {
  version = "~> 2.6"
  region = "${var.aws_region}"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

data "terraform_remote_state" "rds" {
  backend = "s3"
  config = {
    bucket = "${var.terraform_state_bucket}"
    key    = "rds/terraform.tfstate"
    region = "${var.aws_region}"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "${var.terraform_state_bucket}"
    key    = "vpc/terraform.tfstate"
    region = "${var.aws_region}"
  }
}

data "terraform_remote_state" "repo" {
  backend = "s3"
  config = {
    bucket = "${var.terraform_state_bucket}"
    key    = "repo/terraform.tfstate"
    region = "${var.aws_region}"
  }
}

resource "aws_cloudwatch_log_group" "demo" {
  name = "${var.env}-demo"

  tags = {
    env = "${var.env}"
  }
}

resource "aws_ecs_cluster" "app" {
  name = "${var.env}-app-cluster"
}
