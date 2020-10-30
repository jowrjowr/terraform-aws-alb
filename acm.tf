# NOTE: ACM certificate renewal from AWS-generated certs is automatic. see:
# https://docs.aws.amazon.com/acm/latest/userguide/managed-renewal.html

resource "aws_acm_certificate" "loadbalancer_cert" {
  domain_name       = var.acm_domain_name
  validation_method = "DNS"

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

resource "aws_acm_certificate_validation" "loadbalancer_cert" {
  certificate_arn         = aws_acm_certificate.loadbalancer_cert.arn
  validation_record_fqdns = [aws_route53_record.loadbalancer_cert_validation.fqdn]
}
