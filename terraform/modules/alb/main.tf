locals {
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_lb" "this" {
  name                       = "${var.name}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.security_group_id]
  subnets                    = var.subnet_ids
  enable_deletion_protection = false
  drop_invalid_header_fields = true
  idle_timeout               = 60

  tags = merge(local.common_tags, {
    Name = "${var.name}-alb"
    Tier = "presentation"
  })
}

resource "aws_lb_target_group" "application" {
  name        = "${var.name}-tomcat"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}-tomcat"
    Tier = "application"
  })
}

resource "aws_lb_target_group_attachment" "application" {
  target_group_arn = aws_lb_target_group.application.arn
  target_id        = var.target_instance_id
  port             = 8080
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application.arn
  }
}
