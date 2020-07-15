module "logging" {
  source         = "../log-group"
  create         = var.create
  name           = "/aws/lambda/${var.edge ? "us-east-1." : ""}${var.name}"
  retention_days = var.cloudwatch_retention_days
}

// Create a random ID for use with the role name, in case the same function name is used in multiple regions (role names would clash in IAM)
resource "random_id" "role" {
  count       = var.create ? 1 : 0
  byte_length = 8
}

resource "aws_iam_role" "lambda_role" {
  count                 = var.create ? 1 : 0
  name                  = "${var.name}-${random_id.role[0].b64_url}"
  force_detach_policies = true
  assume_role_policy    = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          ${var.edge ? "\"edgelambda.amazonaws.com\"," : ""}
          "lambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

// Attach a policy that allows it to write logs
resource "aws_iam_role_policy" "cloudwatch_write" {
  count  = var.create ? 1 : 0
  name   = "cloudwatch_write"
  role   = aws_iam_role.lambda_role[0].id
  policy = module.logging.logging_policy_data.json

}

// If necessary, attach a policy that allows it to access the VPC
resource "aws_iam_role_policy" "vpc-access" {
  count = var.create && var.vpc_config != null ? 1 : 0
  name  = "vpc-access"
  role  = aws_iam_role.lambda_role[0].id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "ec2:CreateNetworkInterface",
              "ec2:DescribeNetworkInterfaces",
              "ec2:DeleteNetworkInterface"
          ],
          "Resource": "*"
      }
  ]
}
EOF
}

// Attach any policies provided as arguments
resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  count      = var.create ? length(var.role-policy-arns) : 0
  role       = aws_iam_role.lambda_role[0].id
  policy_arn = var.role-policy-arns[count.index]
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

resource "aws_lambda_permission" "allow_execution" {
  count         = var.create ? length(var.execution-services) : 0
  statement_id  = "AllowExecutionFromService-${count.index}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function[0].function_name
  principal     = var.execution-services[count.index].service
  source_arn    = var.execution-services[count.index].arn
}
