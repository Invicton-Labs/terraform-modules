// Create a random ID for use with the role name, in case the same function name is used in multiple regions (role names would clash in IAM)
resource "random_id" "event_rule" {
  count       = length(var.schedules)
  byte_length = 8
}

// Create a rule that runs on a schedule
resource "aws_cloudwatch_event_rule" "lambda" {
  count               = length(var.schedules)
  name                = "${var.name}-${random_id.event_rule[count.index].b64_url}"
  description         = "Schedule for the Lambda function ${var.name}"
  schedule_expression = keys(var.schedules)[count.index]
}

// Create a target for the rule (the Lambda function)
resource "aws_cloudwatch_event_target" "lambda" {
  count = length(var.schedules)
  rule  = aws_cloudwatch_event_rule.lambda[count.index].name
  arn   = aws_lambda_function.function.arn
  input = var.schedules[keys(var.schedules)[count.index]]
}

// Create a permission that allows the CloudWatch event to invoke the Lambda
resource "aws_lambda_permission" "allow_schedule" {
  count         = length(var.schedules)
  statement_id  = "AllowExecutionFromCloudwatchEvent-${count.index}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda[count.index].arn
}
