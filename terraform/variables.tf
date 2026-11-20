variable "aws_region" {
  description = "AWS region for cost monitoring resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource tagging"
  type        = string
  default     = "aws-cost-monitoring"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "personal"
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
  default     = 1
}