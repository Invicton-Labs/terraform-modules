// Random function name
resource "random_id" "function_id" {
  byte_length = 8
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = var.lambda_zip_output_path != null ? var.lambda_zip_output_path : "${path.root}/lambda-botoform-${random_id.function_id.hex}.zip"
}

// Create the Lambda function for triggering on an uploaded image
module "lambda" {
  source           = "../lambda-set"
  name             = "botoform-${random_id.function_id.hex}"
  edge             = false
  handler          = "main.lambda_handler"
  runtime          = "python3.8"
  memory_size      = 128
  timeout          = 300
  archive          = data.archive_file.lambda
  role_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

data "aws_lambda_invocation" "botoform" {
  depends_on    = [module.lambda.complete]
  for_each      = var.scripts
  function_name = module.lambda.lambda.function_name
  input = jsonencode({
    code = each.value
  })
}
