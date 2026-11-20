output "sns_topic_arn" {
  description = "SNS topic ARN used for cost notifications"
  value       = aws_sns_topic.cost_alerts.arn
}

output "sns_subscription_email" {
  description = "Email receiving cost alerts"
  value       = aws_sns_topic_subscription.email.endpoint
}

output "monthly_budget_name" {
  description = "AWS monthly budget name"
  value       = aws_budgets_budget.monthly.name
}

output "monthly_budget_amount" {
  description = "Monthly AWS budget amount"
  value       = aws_budgets_budget.monthly.limit_amount
}

output "cloudwatch_alarm_name" {
  description = "CloudWatch billing alarm name"
  value       = aws_cloudwatch_metric_alarm.billing_alarm.alarm_name
}