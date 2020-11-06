locals {
  shortened_role_name_prefix = length(var.name) <= 31 ? var.name : "${substr(var.name, 0, 15)}-${substr(var.name, length(var.name) - 15, 15)}"
}

resource "aws_iam_role" "lambda_role" {
  count                 = var.iam_role_arn == null ? 1 : 0
  name_prefix           = "${local.shortened_role_name_prefix}-"
  path                  = "/lambda/"
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

data "aws_arn" "lambda_role" {
  arn = var.iam_role_arn == null ? aws_iam_role.lambda_role[0].arn : var.iam_role_arn
}

locals {
  role_name_parts = split("/", data.aws_arn.lambda_role.resource)
}

// Attach a policy that allows it to write logs
resource "aws_iam_role_policy" "cloudwatch_write" {
  count  = var.iam_role_arn == null || var.add_logs_policy ? 1 : 0
  name   = "cloudwatch_write"
  role   = local.role_name_parts[length(local.role_name_parts) - 1]
  policy = module.logging.logging_policy_data.json
}

// If necessary, attach a policy that allows it to access the VPC
resource "aws_iam_role_policy" "vpc-access" {
  count = var.vpc_config != null && var.iam_role_arn == null ? 1 : 0
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
  count      = var.iam_role_arn == null ? length(var.role_policy_arns) : 0
  role       = aws_iam_role.lambda_role[0].id
  policy_arn = var.role_policy_arns[count.index]
}
