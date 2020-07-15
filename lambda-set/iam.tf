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
