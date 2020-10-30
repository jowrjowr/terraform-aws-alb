# monitoring:

# alarm if the backend 5xx's too much.

resource "aws_cloudwatch_metric_alarm" "application_http_5xx" {
  alarm_name          = "${var.name} ${var.project} ${var.environment} http 5xx"
  alarm_description   = "HTTP 5xx errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  threshold           = "1000"
  actions_enabled     = true
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "count"
    return_data = "true"
    metric {
      metric_name = "HTTPCode_Target_5XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = "120"
      stat        = "Sum"
      unit        = "Count"
      dimensions = {
        LoadBalancer = aws_lb.loadbalancer.arn_suffix
      }
    }
  }

  alarm_actions = [
    data.terraform_remote_state.master_terraform.outputs.slack_alert_sns_arn
  ]

  ok_actions = [
    data.terraform_remote_state.master_terraform.outputs.slack_alert_sns_arn
  ]

  tags = {
    Name        = "${var.name} ${var.project} HTTP 5xx errors"
    terraform   = "true"
    project     = var.project
    environment = var.environment
  }
}

# alarm of the load balancer *itself* is making too many errors
# hair trigger since this does not seem to be something that has happened ever.

resource "aws_cloudwatch_metric_alarm" "loadbalancer_http_5xx" {
  alarm_name          = "${var.name} loadbalancer ${var.project} ${var.environment} http 5xx"
  alarm_description   = "loadbalancer-specific HTTP 5xx errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  threshold           = "100"
  actions_enabled     = true
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "count"
    return_data = "true"
    metric {
      metric_name = "HTTPCode_ELB_5XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = "60"
      stat        = "Sum"
      unit        = "Count"
      dimensions = {
        LoadBalancer = aws_lb.loadbalancer.arn_suffix
      }
    }
  }

  alarm_actions = [
    data.terraform_remote_state.master_terraform.outputs.slack_alert_sns_arn
  ]

  ok_actions = [
    data.terraform_remote_state.master_terraform.outputs.slack_alert_sns_arn
  ]

  tags = {
    Name        = "${var.name} ${var.project} loadbalancer HTTP 5xx errors"
    terraform   = "true"
    project     = var.project
    environment = var.environment
  }
}

# keep track of backend response time

resource "aws_cloudwatch_metric_alarm" "application_response_time" {
  alarm_name          = "${var.name} application ${var.project} ${var.environment} response time"
  alarm_description   = "application response time"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  threshold           = "0.500"
  actions_enabled     = true
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "count"
    return_data = "true"
    metric {
      metric_name = "TargetResponseTime"
      namespace   = "AWS/ApplicationELB"
      period      = "120"
      stat        = "p95"
      dimensions = {
        LoadBalancer = aws_lb.loadbalancer.arn_suffix
      }
    }
  }

  alarm_actions = [
    data.terraform_remote_state.master_terraform.outputs.slack_alert_sns_arn
  ]

  ok_actions = [
    data.terraform_remote_state.master_terraform.outputs.slack_alert_sns_arn
  ]

  tags = {
    Name        = "${var.name} ${var.project} loadbalancer response time"
    terraform   = "true"
    project     = var.project
    environment = var.environment
  }
}
