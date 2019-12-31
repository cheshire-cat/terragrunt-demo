### Task Definitions

resource "aws_iam_role" "ecs_execution_role" {
  name               = "${var.env}_ecs_task_execution_role"
  assume_role_policy = "${file("${path.module}/templates/ecs_task_execution_role.json")}"
}

resource "aws_iam_role_policy" "ecs_execution_role_policy" {
  name   = "${var.env}_ecs_execution_role_policy"
  policy = "${file("${path.module}/templates/ecs_execution_role_policy.json")}"
  role   = "${aws_iam_role.ecs_execution_role.id}"
}

data "template_file" "app" {
  template = "${file("${path.module}/templates/app_container_definition.json")}"

  vars {
    image           = "${data.terraform_remote_state.repo.repository_url}:latest"
    # TODO change to secrets and master key in prod
    secret_key_base = "${var.secret_key_base}"
    database_url    = "postgresql://${data.terraform_remote_state.rds.db_username}:${data.terraform_remote_state.rds.db_password}@${data.terraform_remote_state.rds.db_endpoint}/${data.terraform_remote_state.rds.db_name}?pool=5"
    log_group       = "${aws_cloudwatch_log_group.demo.name}"
    log_region      = "${var.aws_region}"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.env}_app"
  container_definitions    = "${data.template_file.app.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "1024"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  # task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"
  depends_on               = ["aws_iam_role_policy.ecs_execution_role_policy"]

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "db_migrate" {
  template = "${file("${path.module}/templates/db_migrate_container_definition.json")}"

  vars {
    image           = "${data.terraform_remote_state.repo.repository_url}:latest"
    # TODO change to secrets and master key in prod
    secret_key_base = "${var.secret_key_base}"
    database_url    = "postgresql://${data.terraform_remote_state.rds.db_username}:${data.terraform_remote_state.rds.db_password}@${data.terraform_remote_state.rds.db_endpoint}/${data.terraform_remote_state.rds.db_name}?pool=5"
    log_group       = "${aws_cloudwatch_log_group.demo.name}"
    log_region      = "${var.aws_region}"
  }
}

resource "aws_ecs_task_definition" "db_migrate" {
  family                   = "${var.env}_db_migrate"
  container_definitions    = "${data.template_file.db_migrate.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  # task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"
  depends_on               = ["aws_iam_role_policy.ecs_execution_role_policy"]
}
