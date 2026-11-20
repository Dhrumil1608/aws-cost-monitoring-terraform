# --------------------------------------------------
# SNS Topic
# --------------------------------------------------

resource "aws_sns_topic" "cost_alerts" {
  name = "${var.project_name}-alerts"
}

# --------------------------------------------------
# SNS Email Subscription
# --------------------------------------------------

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.cost_alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# --------------------------------------------------
# AWS Monthly Budget
# --------------------------------------------------

resource "aws_budgets_budget" "monthly" {
  name         = "${var.project_name}-monthly-budget"
  budget_type  = "COST"
  limit_amount = var.monthly_budget
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  # Budget alert at 80%
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = []
    subscriber_sns_topic_arns  = [aws_sns_topic.cost_alerts.arn]
  }

  # Budget alert at 100%
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = []
    subscriber_sns_topic_arns  = [aws_sns_topic.cost_alerts.arn]
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
  }
}

# --------------------------------------------------
# CloudWatch Billing Alarm
# --------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  alarm_name          = "${var.project_name}-billing-alarm"
  alarm_description   = "Alarm when estimated AWS charges exceed $5"
  comparison_operator = "GreaterThanThreshold"

  evaluation_periods = 1
  metric_name        = "EstimatedCharges"
  namespace          = "AWS/Billing"
  period             = 21600
  statistic          = "Maximum"

  threshold = var.monthly_budget

  treat_missing_data = "notBreaching"

  dimensions = {
    Currency = "USD"
  }

  alarm_actions = [
    aws_sns_topic.cost_alerts.arn
  ]

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
  }
}