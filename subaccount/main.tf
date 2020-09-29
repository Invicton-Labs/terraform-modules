resource "aws_organizations_account" "subaccount" {
  provider                   = aws
  name                       = var.name
  email                      = var.email
  iam_user_access_to_billing = var.billing_access ? "ALLOW" : "DENY"
  role_name                  = var.role_name
  parent_id                  = var.parent_id
}

locals {
  subaccount_role_arn = "arn:aws:iam::${aws_organizations_account.subaccount.id}:role/${var.role_name}"
}

// Configure the default provider region
provider "aws" {
  alias   = "subaccount"
  region  = var.region
  profile = var.aws_profile
  assume_role {
    role_arn = local.subaccount_role_arn
  }
}

// Create an S3 bucket for storing the state files for the subaccounts
resource "aws_s3_bucket" "terraform_state" {
  provider = aws.subaccount
  bucket   = "terraform-state-${aws_organizations_account.subaccount.id}"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

// Create a DynamoDB table for the lock file
resource "aws_dynamodb_table" "terraform-state-lock" {
  provider     = aws.subaccount
  name         = "terraform_lock"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}

// Create a Terraform user
resource "aws_iam_user" "terraform" {
  provider = aws.subaccount
  name     = "Terraform"
}

// Attach the AWS built-in Admin policy
resource "aws_iam_user_policy_attachment" "terraform" {
  provider   = aws.subaccount
  user       = aws_iam_user.terraform.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

// Create an access key for this user
resource "aws_iam_access_key" "terraform" {
  provider = aws.subaccount
  user     = aws_iam_user.terraform.name
  pgp_key  = var.pgp_key
}

// Create a delegation set for this account
resource "aws_route53_delegation_set" "delegation" {
  provider = aws.subaccount
}

// Create a config file in the S3 bucket with values specifically for this subaccount
resource "aws_s3_bucket_object" "config" {
  provider = aws.subaccount
  bucket   = aws_s3_bucket.terraform_state.id
  key      = "config.json"
  content = jsonencode(merge({
    route53_delegation_set_id = aws_route53_delegation_set.delegation.id
  }, var.config_map))
  // Must add the content-type metadata so the body can be loaded by Terraform data resource
  content_type = "application/json"
}
