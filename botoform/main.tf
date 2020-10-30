// Random function name
resource "random_uuid" "function_id" {}

// Create the Lambda function for triggering on an uploaded image
module "lambda" {
  source           = "../lambda-set"
  name             = "botoform-${random_uuid.function_id.result}"
  edge             = false
  handler          = "main.lambda_handler"
  runtime          = "python3.8"
  memory_size      = 128
  timeout          = 300
  directory        = "${path.module}/lambda"
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
