// Create a random ID for use with the role name, in case the same function name is used in multiple regions (role names would clash in IAM)
resource "random_id" "event_rule" {
  count       = var.create && var.schedule != null ? 1 : 0
  byte_length = 8
}

resource "aws_cloudwatch_event_rule" "lambda" {
  count               = var.create && var.schedule != null ? 1 : 0
  name                = "${var.name}-${random_id.event_rule[0].b64_url}"
  description         = "Schedule for the Lambda function ${var.name}"
  schedule_expression = var.schedule
}

resource "aws_cloudwatch_event_target" "lambda" {
  count = var.create && var.schedule != null ? 1 : 0
  rule  = aws_cloudwatch_event_rule.lambda[0].name
  arn   = aws_lambda_function.function[0].arn
}

resource "aws_lambda_permission" "allow_schedule" {
  count         = var.create && var.schedule != null ? 1 : 0
  statement_id  = "AllowExecutionFromCloudwatchEvent"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda[0].arn
}
