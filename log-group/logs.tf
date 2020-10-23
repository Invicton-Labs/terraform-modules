// Create the logs group for the function to use
resource "aws_cloudwatch_log_group" "loggroup" {
  name              = var.name
  retention_in_days = var.retention_days
}

data "aws_iam_policy_document" "logging" {
  statement {
    actions = [
      "logs:CreateLogStream"
    ]
    resources = [
      "${aws_cloudwatch_log_group.loggroup.arn}"
    ]
  }
  statement {
    actions = [
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.loggroup.arn}:*"
    ]
  }
}

resource "aws_cloudwatch_log_subscription_filter" "subscription" {
  count           = var.subscription_lambda_arn != null ? 1 : 0
  name            = var.subscription_name
  log_group_name  = aws_cloudwatch_log_group.loggroup.name
  filter_pattern  = var.subscription_filter
  destination_arn = var.subscription_lambda_arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  count         = var.subscription_lambda_arn != null && var.apply_subscription_permission ? 1 : 0
  action        = "lambda:InvokeFunction"
  function_name = var.subscription_lambda_arn
  principal     = "logs.amazonaws.com"
  source_arn    = aws_cloudwatch_log_group.loggroup.arn
}
