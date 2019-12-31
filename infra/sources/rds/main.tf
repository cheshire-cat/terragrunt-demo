provider "aws" {
  version = "~> 2.6"
  region = "${var.aws_region}"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "${var.terraform_state_bucket}"
    key    = "vpc/terraform.tfstate"
    region = "${var.aws_region}"
  }
}

module "rds" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.env}-demo-db"

  engine            = "postgres"
  engine_version    = "11"
  instance_class    = "${var.db_instance}"
  allocated_storage = 5
  # to create db faster
  # change this in production
  storage_encrypted = false

  # kms_key_id        = "arm:aws:kms:<region>:<account id>:key/<kms key id>"
  name     = "${var.db_name}"
  username = "${var.db_username}"
  password = "${var.db_password}"
  port     = "5432"

  # created in vpc module
  subnet_ids = "${data.terraform_remote_state.vpc.database_subnets}"
  vpc_security_group_ids = ["${module.rds_sg.this_security_group_id}"]

  # todo true in prod
  multi_az = false

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"
  
  # disable backups to create DB faster
  # change this in production
  backup_retention_period = 0

  tags = {
    env = "${var.env}"
  }

  enabled_cloudwatch_logs_exports = ["postgresql"]

  family = "postgres11"

  major_engine_version = "11"

  final_snapshot_identifier = "${var.env}-demo-db"

  # TODO: for production
  # deletion_protection = true
  
  vpc_security_group_ids = ["${module.rds_sg.this_security_group_id}"]
}

module "rds_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/postgresql"

  name = "${var.env}-rds-sg"
  description = "Security group for postgresql ${var.env}-rsd"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

  ingress_cidr_blocks = ["10.0.0.0/16"]
}
