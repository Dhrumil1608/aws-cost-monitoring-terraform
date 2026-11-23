
variable "aws_region" {
  description = "AWS region for cost monitoring resources. Billing metrics require us-east-1."
  type        = string

  validation {
    condition     = var.aws_region == "us-east-1"
    error_message = "AWS Billing EstimatedCharges metrics are available only in us-east-1. Set aws_region to us-east-1."
  }
}

variable "aws_profile" {
  description = "AWS CLI profile used by Terraform"
  type        = string
}

variable "allowed_account_ids" {
  description = "AWS account IDs Terraform is permitted to manage"
  type        = list(string)

  validation {
    condition     = length(var.allowed_account_ids) > 0
    error_message = "At least one allowed AWS account ID must be provided."
  }
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "owner" {
  description = "Resource owner"
  type        = string
}

variable "notification_email" {
  description = "Email address to receive AWS cost alerts"
  type        = string
}

variable "monthly_budget" {
  description = "Monthly AWS spending budget in USD"
  type        = number

  validation {
    condition     = var.monthly_budget > 0
    error_message = "Monthly budget must be greater than zero."
  }
}

variable "budget_thresholds" {
  description = "AWS Budget actual-spend notification thresholds as percentages"
  type        = list(number)

  validation {
    condition = (
      length(var.budget_thresholds) > 0 &&
      alltrue([
        for threshold in var.budget_thresholds :
        threshold > 0 && threshold <= 100
      ]) &&
      length(distinct(var.budget_thresholds)) == length(var.budget_thresholds)
    )
    error_message = "Provide unique budget thresholds greater than 0 and no greater than 100."
  }
}
