terraform {
  experiments = [module_variable_optional_attrs]
}

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

provider "aws" {
  alias   = "subaccount"
  region  = var.region_primary
  profile = var.aws_profile
  assume_role {
    role_arn = local.subaccount_role_arn
  }
}
provider "aws" {
  alias   = "subaccount_secondary"
  region  = var.region_secondary
  profile = var.aws_profile
  assume_role {
    role_arn = local.subaccount_role_arn
  }
}

module "s3-terraform-state" {
  source        = "github.com/Imperative-Systems-Inc/terraform-modules/replicated-s3"
  name_prefix   = "terraform-state-${aws_organizations_account.subaccount.id}"
  force_destroy = false
  encrypt       = true
  versioning    = true
  providers = {
    aws.primary   = aws.subaccount
    aws.secondary = aws.subaccount_secondary
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

// If desired, create a hosted zone for a domain
resource "aws_route53_zone" "zone" {
  provider          = aws.subaccount
  count             = var.hosted_zone_domain == null ? 0 : 1
  name              = var.hosted_zone_domain
  delegation_set_id = aws_route53_delegation_set.delegation.id
}

// If desired, add records to the hosted zone
resource "aws_route53_record" "records" {
  provider        = aws.subaccount
  for_each        = var.hosted_zone_domain == null ? {} : var.hosted_zone_records
  allow_overwrite = true
  zone_id         = aws_route53_zone.zone[0].id
  name            = each.value.name
  type            = each.value.type
  ttl             = each.value.ttl
  records         = each.value.records
}

// Create a config file in the S3 bucket with values specifically for this subaccount
resource "aws_s3_bucket_object" "config" {
  provider = aws.subaccount
  bucket   = module.s3-terraform-state.primary_bucket.id
  key      = "config.json"
  content = jsonencode(merge(
    {
      route53_delegation_set_id = aws_route53_delegation_set.delegation.id
      terraform_state = {
        primary_bucket_arn   = module.s3-terraform-state.primary_bucket.arn
        secondary_bucket_arn = module.s3-terraform-state.secondary_bucket.arn
        dynamodb_table_arn   = aws_dynamodb_table.terraform-state-lock.arn
      }
    },
    var.hosted_zone_domain == null ? {} : {
      hosted_zone_id = aws_route53_zone.zone[0].id
    },
    var.config_map
  ))
  // Must add the content-type metadata so the body can be loaded by Terraform data resource
  content_type = "application/json"
}

// If desired, set an IAM account password policy
resource "aws_iam_account_password_policy" "policy" {
  count                          = var.iam_account_password_policy == null ? 0 : 1
  allow_users_to_change_password = var.iam_account_password_policy.allow_users_to_change_password
  hard_expiry                    = var.iam_account_password_policy.hard_expiry
  max_password_age               = var.iam_account_password_policy.max_password_age
  minimum_password_length        = var.iam_account_password_policy.minimum_password_length
  password_reuse_prevention      = var.iam_account_password_policy.password_reuse_prevention
  require_lowercase_characters   = var.iam_account_password_policy.require_lowercase_characters
  require_numbers                = var.iam_account_password_policy.require_numbers
  require_symbols                = var.iam_account_password_policy.require_symbols
  require_uppercase_characters   = var.iam_account_password_policy.require_uppercase_characters
}
