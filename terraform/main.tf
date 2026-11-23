
# Get the AWS account ID of the currently authenticated account
data "aws_caller_identity" "current" {}

# SNS Topic - Cost Alerts
resource "aws_sns_topic" "cost_alerts" {
  name = "${var.project_name}-alerts"

  tags = {
    Name = "${var.project_name}-alerts"
  }
}

# SNS Topic Policy - Allow AWS Budgets and CloudWatch to Publish
resource "aws_sns_topic_policy" "cost_alerts" {
  arn = aws_sns_topic.cost_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowAWSBudgetsToPublish"
        Effect = "Allow"

        Principal = {
          Service = "budgets.amazonaws.com"
        }

        Action   = "SNS:Publish"
        Resource = aws_sns_topic.cost_alerts.arn

        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid    = "AllowCloudWatchAlarmsToPublish"
        Effect = "Allow"

        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }

        Action   = "SNS:Publish"
        Resource = aws_sns_topic.cost_alerts.arn

        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }

          ArnLike = {
            "aws:SourceArn" = aws_cloudwatch_metric_alarm.billing_alarm.arn
          }
        }
      }
    ]
  })
}

# SNS Email Subscription
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.cost_alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# AWS Budget - Monthly Cost Monitoring
resource "aws_budgets_budget" "monthly" {
  name         = "${var.project_name}-monthly-budget"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  dynamic "notification" {
    for_each = var.budget_thresholds

    content {
      comparison_operator       = "GREATER_THAN"
      threshold                 = notification.value
      threshold_type            = "PERCENTAGE"
      notification_type         = "ACTUAL"
      subscriber_sns_topic_arns = [aws_sns_topic.cost_alerts.arn]
    }
  }

  depends_on = [
    aws_sns_topic_policy.cost_alerts
  ]

  tags = {
    Name = "${var.project_name}-monthly-budget"
  }
}

# CloudWatch Billing Alarm
resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  alarm_name        = "${var.project_name}-billing-alarm"
  alarm_description = "Alarm when estimated AWS charges exceed ${var.monthly_budget} USD."

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 21600
  statistic           = "Maximum"
  threshold           = var.monthly_budget

  alarm_actions = [aws_sns_topic.cost_alerts.arn]
  ok_actions    = [aws_sns_topic.cost_alerts.arn]

  treat_missing_data = "notBreaching"

  dimensions = {
    Currency = "USD"
  }

  tags = {
    Name = "${var.project_name}-billing-alarm"
  }
}
