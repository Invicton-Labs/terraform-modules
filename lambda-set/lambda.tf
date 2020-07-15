// Create the Cloudwatch log group
module "logging" {
  source         = "../log-group"
  create         = var.create
  name           = "/aws/lambda/${var.edge ? "us-east-1." : ""}${var.name}"
  retention_days = var.cloudwatch_retention_days
}

// Create the ZIP file for the Lambda
data "archive_file" "archive" {
  count       = var.create && var.archive.output_path == "" ? 1 : 0
  type        = "zip"
  source_dir  = var.directory
  output_path = "${var.directory}.zip"
}

// Create the actual function
resource "aws_lambda_function" "function" {
  count            = var.create ? 1 : 0
  depends_on       = [module.logging.complete]
  filename         = local.archive.output_path
  function_name    = var.name
  role             = aws_iam_role.lambda_role[0].arn
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

// For each service that should be able to execute this function, add a permission to do so
resource "aws_lambda_permission" "allow_execution" {
  count         = var.create ? length(var.execution_services) : 0
  statement_id  = "AllowExecutionFromService-${count.index}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function[0].function_name
  principal     = var.execution_services[count.index].service
  source_arn    = var.execution_services[count.index].arn
}
