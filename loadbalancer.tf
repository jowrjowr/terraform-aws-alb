
# AWS docu:
# https://www.terraform.io/docs/providers/aws/r/lb_target_group.html
resource "aws_lb_target_group" "target" {
  name        = "${var.name}-${var.project}-${var.environment}"
  protocol    = "HTTP"
  port        = var.alb_target_port
  target_type = "instance"
  vpc_id      = var.vpc_id
  tags = {
    Name        = "${var.name} ${var.project}"
    terraform   = "true"
    project     = var.project
    environment = var.environment
  }
  health_check {
    enabled             = var.alb_health_check_enabled
    path                = var.alb_health_check_path
    protocol            = "HTTP"
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 5
    timeout             = 3
  }
}

# external resources are what the world sees so these will always be
# on 80/443 as that's what one would expect.

resource "aws_lb_listener" "external_http" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  protocol          = "HTTP"
  port              = "80"

  default_action {
    target_group_arn = aws_lb_target_group.target.arn
    type             = "forward"
  }
}

# for allowed SSL policies see:
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html

resource "aws_lb_listener" "external_https" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  protocol          = "HTTPS"
  port              = "443"
  ssl_policy        = var.alb_ssl_policy
  certificate_arn   = aws_acm_certificate_validation.loadbalancer_cert.certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.target.arn
    type             = "forward"
  }
}

# one attachment per target group
resource "aws_autoscaling_attachment" "external_http" {
  autoscaling_group_name = var.alb_autoscaling_target
  alb_target_group_arn   = aws_lb_target_group.target.arn
}

resource "aws_lb" "loadbalancer" {
  name                       = "${var.name}-${var.project}-${var.environment}"
  internal                   = false
  load_balancer_type         = "application"
  enable_deletion_protection = false
  ip_address_type            = "dualstack"
  security_groups            = concat([aws_security_group.loadbalancer.id], var.alb_additional_security_groups)
  subnets                    = var.alb_subnets

  tags = {
    Name        = "${var.name} ${var.project}"
    terraform   = "true"
    project     = var.project
    environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }

}
