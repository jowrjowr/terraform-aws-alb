# SSL certificate validation

resource "aws_route53_record" "loadbalancer_cert_validation" {
  name    = aws_acm_certificate.loadbalancer_cert.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.loadbalancer_cert.domain_validation_options.0.resource_record_type
  zone_id = data.terraform_remote_state.master_terraform.outputs.company_zone_id
  records = [aws_acm_certificate.loadbalancer_cert.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

# NOTE: ipv4 and ipv6 are split because generally we'd like to always serve both
# and that a public facing ALB gives us v6 for free for the asking.

# AWS documentation on alias records:
# https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-choosing-alias-non-alias.html

resource "aws_route53_record" "loadbalancer_v4_alias" {
  zone_id = data.terraform_remote_state.master_terraform.outputs.company_zone_id
  name    = var.acm_domain_name
  type    = "A"

  alias {
    name                   = aws_lb.loadbalancer.dns_name
    zone_id                = aws_lb.loadbalancer.zone_id
    evaluate_target_health = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "api_v6_alias" {
  zone_id = data.terraform_remote_state.master_terraform.outputs.company_zone_id
  name    = var.acm_domain_name
  type    = "AAAA"

  alias {
    name                   = aws_lb.loadbalancer.dns_name
    zone_id                = aws_lb.loadbalancer.zone_id
    evaluate_target_health = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
