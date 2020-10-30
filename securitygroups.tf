# external http specifically only allows access to elixir
resource "aws_security_group" "loadbalancer" {
  name        = "${var.name} ${var.project} loadbalancer"
  description = "loadbalancer policy"
  vpc_id      = var.vpc_id

  ingress {
    description      = "global http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "global https"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # the egress is actually necessary with how ALB security policies work
  # an improvement would be to limit the cidr_blocks to the specific subnets

  egress {
    description = "backend target"
    from_port   = var.alb_target_port
    to_port     = var.alb_target_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.name} ${var.project} loadbalancer"
    terraform   = "true"
    project     = var.project
    environment = var.environment
  }
}
