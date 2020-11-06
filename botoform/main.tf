// Random function name
resource "random_id" "function_id" {
  byte_length = 8
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = var.lambda_zip_output_path != null ? var.lambda_zip_output_path : "${path.module}/archives/lambda-botoform-${random_id.function_id.hex}.zip"
}

// Create the Lambda function for triggering on an uploaded image
module "lambda" {
  source           = "../lambda-set"
  name             = "botoform-${random_id.function_id.hex}"
  edge             = false
  handler          = "main.lambda_handler"
  runtime          = "python3.8"
  memory_size      = var.memory_size
  timeout          = var.timeout
  archive          = data.archive_file.lambda
  role_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

// Invoke the lambda once for each provided set of scripts
data "aws_lambda_invocation" "botoform" {
  depends_on = [module.lambda.complete]
  for_each = {
    for key in keys(var.scripts) :
    key => var.scripts[key]
    if var.scripts[key].triggers == null
  }
  function_name = module.lambda.lambda.function_name
  input         = jsonencode(each.value.scripts)
}

locals {
  decoded_results = {
    for key in keys(data.aws_lambda_invocation.botoform) :
    key => jsondecode(data.aws_lambda_invocation.botoform[key].result)
  }
}
