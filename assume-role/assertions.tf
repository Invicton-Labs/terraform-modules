// Check if AWS is installed
module "aws_exists" {
  source  = "../command-exists"
  command = "aws"
}

// Make sure AWS is installed
module "assert_aws_exists" {
  source        = "../assert"
  condition     = module.aws_exists.exists
  error_message = "'aws' command not found. AWS CLI must be installed to use the 'assume-role' module."
}
