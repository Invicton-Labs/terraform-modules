output "log_group" {
  depends_on = [aws_cloudwatch_log_group.loggroup]
  value      = var.create ? aws_cloudwatch_log_group.loggroup[0] : null
}

output "logging_policy_data" {
  depends_on = [data.aws_iam_policy_document.logging]
  value      = var.create ? data.aws_iam_policy_document.logging[0] : null
}

// A flag for determining when everything in this module has been created
output "complete" {
  depends_on = [
    aws_cloudwatch_log_group.loggroup,
    aws_cloudwatch_log_subscription_filter.subscription,
    aws_lambda_permission.allow_cloudwatch
  ]
  value = true
}
