// Create a random ID for use with the role name, in case the same function name is used in multiple regions (role names would clash in IAM)
resource "random_id" "event_rule" {
  count       = var.create ? length(var.schedules) : 0
  byte_length = 8
}

// Create a rule that runs on a schedule
resource "aws_cloudwatch_event_rule" "lambda" {
  count               = var.create ? length(var.schedules) : 0
  name                = "${var.name}-${random_id.event_rule[count.index].b64_url}"
  description         = "Schedule for the Lambda function ${var.name}"
  schedule_expression = var.schedules[count.index]
}

// Create a target for the rule (the Lambda function)
resource "aws_cloudwatch_event_target" "lambda" {
  count = var.create ? length(var.schedules) : 0
  rule  = aws_cloudwatch_event_rule.lambda[count.index].name
  arn   = aws_lambda_function.function[0].arn
}

// Create a permission that allows the CloudWatch event to invoke the Lambda
resource "aws_lambda_permission" "allow_schedule" {
  count         = var.create ? length(var.schedules) : 0
  statement_id  = "AllowExecutionFromCloudwatchEvent-${count.index}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda[count.index].arn
}
