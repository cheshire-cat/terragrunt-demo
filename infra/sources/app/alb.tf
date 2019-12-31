### ALB

resource "aws_alb_target_group" "app_alb_target_group" {
  name     = "${var.env}-alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.vpc.vpc_id}"
  target_type = "ip"

  depends_on = ["aws_alb.alb_app"]

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "app_alb_inbound_sg" {
  name        = "${var.env}-app-alb-inbound-sg"
  description = "Allow HTTP,HTTPS,ICMP from Anywhere into ALB"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.env}-app-alb-inbound-sg"
  }
}

resource "aws_alb" "alb_app" {
  name            = "${var.env}-alb-app"
  subnets         = ["${data.terraform_remote_state.vpc.public_subnets}"]
  security_groups = ["${aws_security_group.app_alb_inbound_sg.id}"]

  # TODO: logs
  # access_logs {
  #   bucket = "${var.access_log_bucket}"
  #   prefix = "${var.access_log_prefix}"
  # }

  tags {
    Name        = "${var.env}-alb-app"
    Environment = "${var.env}"
  }
}

resource "aws_alb_listener" "app" {
  load_balancer_arn = "${aws_alb.alb_app.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.app_alb_target_group.arn}"
    type             = "forward"
  }
}
