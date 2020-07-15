output "lambda" {
  value = var.create ? aws_lambda_function.function[0] : null
}
output "log_group" {
  value = var.create ? module.logging.log_group : null
}

// A flag for determining when everything in this module has been created
output "complete" {
  depends_on = [
    module.logging.complete,
    aws_iam_role_policy.cloudwatch_write,
    aws_iam_role_policy.vpc-access,
    aws_iam_role_policy_attachment.role_policy_attachment,
    aws_lambda_function.function,
    aws_lambda_permission.allow_execution,
    aws_lambda_permission.allow_schedule,
    ws_cloudwatch_event_target.lambda
  ]
  value = true
}
