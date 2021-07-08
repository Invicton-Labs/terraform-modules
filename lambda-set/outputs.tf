output "lambda" {
  value = aws_lambda_function.function
}
output "log_group" {
  value = module.logging.log_group
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
    aws_cloudwatch_event_target.lambda,
    aws_lambda_function_event_invoke_config.config
  ]
  value = true
}
