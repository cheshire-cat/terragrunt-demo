### Service

resource "aws_security_group" "ecs" {
  name        = "${var.env}-ecs-sg"
  description = "allow inbound access from the ALB only"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = ["${aws_security_group.app_alb_inbound_sg.id}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "app" {
  name            = "${var.env}-app"
  # takes the latest version by default
  task_definition = "${aws_ecs_task_definition.app.family}"
  desired_count   = 2
  launch_type     = "FARGATE"
  cluster         = "${aws_ecs_cluster.app.id}"

  network_configuration {
    security_groups = ["${aws_security_group.ecs.id}"]
    subnets = ["${data.terraform_remote_state.vpc.private_subnets}"]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.app_alb_target_group.arn}"
    container_name   = "app"
    container_port   = 80
  }

  depends_on = ["aws_alb_listener.app"]
}
