// Create the Cloudwatch log group
module "logging" {
  source         = "../log-group"
  name           = "/aws/lambda/${var.edge ? "us-east-1." : ""}${var.name}"
  retention_days = var.cloudwatch_retention_days
}

// Create the ZIP file for the Lambda
data "archive_file" "archive" {
  count       = var.archive.output_path == "" ? 1 : 0
  type        = "zip"
  source_dir  = var.directory
  output_path = "${var.directory}.zip"
}

// Create the actual function
resource "aws_lambda_function" "function" {
  depends_on       = [module.logging.complete]
  filename         = local.archive.output_path
  function_name    = var.name
  role             = aws_iam_role.lambda_role.arn
  handler          = var.handler
  source_code_hash = local.archive.output_base64sha256
  runtime          = var.runtime
  memory_size      = var.memory_size
  timeout          = var.timeout
  publish          = true
  // Only enclude the environment block if there are any environment vars provided
  dynamic "environment" {
    for_each = length(var.environment) > 0 ? [1] : []
    content {
      variables = var.environment
    }
  }
  // Only enclude the environment block if there are any environment vars provided
  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [1] : []
    content {
      subnet_ids         = var.vpc_config.subnet_ids
      security_group_ids = var.vpc_config.security_group_ids
    }
  }
}

// Configure async call config
resource "aws_lambda_function_event_invoke_config" "config" {
  function_name                = aws_lambda_function.function.function_name
  maximum_event_age_in_seconds = var.maximum_event_age_in_seconds
  maximum_retry_attempts       = var.maximum_retry_attempts
}

// For each service that should be able to execute this function, add a permission to do so
resource "aws_lambda_permission" "allow_execution" {
  count         = length(var.execution_services)
  statement_id  = "AllowExecutionFromService-${count.index}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = var.execution_services[count.index].service
  source_arn    = var.execution_services[count.index].arn
}
