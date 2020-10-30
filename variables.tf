variable "environment" {
  description = "environment name"
  default     = "dev"
  type        = string
}

variable "project" {
  description = "project tag"
  type        = string
}

variable "name" {
  description = "allows for additional sub-project naming"
  default     = "main"
  type        = string
}

variable "account_id" {
  description = "primary AWS account ID"
  type        = number
}

variable "acm_domain_name" {
  description = "FQDN of ACM certificate"
  type        = string
}

variable "alb_target_port" {
  description = "the backend port the ALB throws traffic at"
  type        = number
}

variable "alb_health_check_path" {
  description = "the http path the health check will use"
  default     = "/"
  type        = string
}

variable "alb_health_check_enabled" {
  description = "perform the health check at all?"
  default     = true
  type        = bool
}

variable "alb_ssl_policy" {
  description = "the AWS SSL policy to use for HTTPS"
  default     = "ELBSecurityPolicy-2016-08"
  type        = string
}

variable "alb_autoscaling_target" {
  description = "autoscaling group target ID"
  type        = string
}

variable "alb_additional_security_groups" {
  description = "list of additional security groups"
  default     = []
  type        = list(string)
}

variable "alb_subnets" {
  description = "the list of subnets the ALB can start within"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
