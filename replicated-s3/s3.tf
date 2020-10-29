// Get the canonical user ID
data "aws_canonical_user_id" "current_account" {}

locals {
  // If CloudFront logging is enabled, add the correct grant to the list
  primary_grants = var.cloudfront_logging ? concat(var.primary_grants, [{
    // The CloudFront account canonical ID (https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html)
    id          = "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0"
    permissions = ["FULL_CONTROL"]
    type        = "CanonicalUser"
    uri         = null
  }]) : var.primary_grants
  // If the ACL is the default ("private") but a grant was specified, don't set an ACL
  // If the ACL was anything other than default but a grant was specified, an error will be thrown by Terraform
  primary_acl   = lower(var.primary_acl) == "private" && length(local.primary_grants) > 0 ? null : var.primary_acl
  secondary_acl = lower(var.secondary_acl) == "private" && length(var.secondary_grants) > 0 ? null : var.secondary_acl

  // If a grant was specified but the ACL was set as the default value, add a grant for the owner account
  primary_grants_acl = lower(var.primary_acl) == "private" && length(local.primary_grants) > 0 ? concat(local.primary_grants, [{
    id          = data.aws_canonical_user_id.current_account.id
    permissions = ["FULL_CONTROL"]
    type        = "CanonicalUser"
    uri         = null
  }]) : local.primary_grants
  secondary_grants_acl = lower(var.secondary_acl) == "private" && length(var.secondary_grants) > 0 ? concat(var.secondary_grants, [{
    id          = data.aws_canonical_user_id.current_account.id
    permissions = ["FULL_CONTROL"]
    type        = "CanonicalUser"
    uri         = null
  }]) : var.secondary_grants
}

resource "aws_s3_bucket" "primary" {
  provider      = aws.primary
  bucket        = local.primary_bucket_name
  acl           = local.primary_acl
  force_destroy = var.force_destroy
  versioning {
    enabled = true
  }
  // Add grants if any were specified
  dynamic "grant" {
    for_each = local.primary_grants_acl
    content {
      id          = grant.value.id
      type        = grant.value.type
      permissions = grant.value.permissions
      uri         = grant.value.uri
    }
  }
  // If versioning is enabled and a transition timeframe has been set, configure that transition
  dynamic "lifecycle_rule" {
    for_each = var.noncurrent_version_transition_days != null ? [1] : []
    content {
      enabled = true
      // Non-current versions go straight to a different class
      noncurrent_version_transition {
        days          = var.noncurrent_version_transition_days
        storage_class = var.noncurrent_version_transition_class
      }
    }
  }
  dynamic "lifecycle_rule" {
    // If versioning isn't desired, but non-versioning isn't possible (due to replication),
    // add a rule to delete old versions as quickly as possible
    for_each = ! var.versioning ? [1] : []
    content {
      enabled = true
      noncurrent_version_expiration {
        days = 1
      }
    }
  }
  // If a transition period has been defined for current file versions, configure that transition
  dynamic "lifecycle_rule" {
    for_each = var.transition_days != null ? [1] : []
    content {
      enabled = true
      transition {
        days          = var.transition_days
        storage_class = var.transition_class
      }
    }
  }
  dynamic "server_side_encryption_configuration" {
    for_each = var.encrypt ? [1] : []
    content {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
    }
  }
  dynamic "cors_rule" {
    for_each = length(var.cors_origins) > 0 ? [1] : []
    content {
      allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
      allowed_origins = var.cors_origins
      allowed_headers = ["*"]
    }
  }
  dynamic "website" {
    for_each = var.website != null ? [1] : []
    content {
      index_document           = lookup(var.website, "index_document", null)
      error_document           = lookup(var.website, "error_document", null)
      redirect_all_requests_to = lookup(var.website, "redirect_all_requests_to", null)
      routing_rules            = lookup(var.website, "routing_rules", null)
    }
  }
  replication_configuration {
    role = aws_iam_role.s3-replicator.arn
    rules {
      id       = "Cross-region replication"
      status   = "Enabled"
      priority = 0
      destination {
        bucket = aws_s3_bucket.secondary.arn
      }
    }
  }
}

resource "aws_s3_bucket" "secondary" {
  provider      = aws.secondary
  bucket        = local.secondary_bucket_name
  acl           = local.secondary_acl
  force_destroy = var.force_destroy
  versioning {
    enabled = true
  }
  // Add grants if any were specified
  dynamic "grant" {
    for_each = local.secondary_grants_acl
    content {
      id          = grant.value.id
      type        = grant.value.type
      permissions = grant.value.permissions
      uri         = grant.value.uri
    }
  }
  // If versioning is enabled and a transition timeframe has been set, configure that transition
  dynamic "lifecycle_rule" {
    for_each = var.noncurrent_version_transition_days != null ? [1] : []
    content {
      enabled = true
      // Non-current versions go straight to a different class
      noncurrent_version_transition {
        days          = var.noncurrent_version_transition_days
        storage_class = var.noncurrent_version_transition_class
      }
    }
  }
  dynamic "lifecycle_rule" {
    // If versioning isn't desired, but non-versioning isn't possible (due to replication),
    // add a rule to delete old versions as quickly as possible
    for_each = ! var.versioning ? [1] : []
    content {
      enabled = true
      noncurrent_version_expiration {
        days = 1
      }
    }
  }
  // If a transition period has been defined for current file versions, configure that transition
  dynamic "lifecycle_rule" {
    for_each = var.transition_days != null ? [1] : []
    content {
      enabled = true
      transition {
        days          = var.transition_days
        storage_class = var.transition_class
      }
    }
  }
  dynamic "server_side_encryption_configuration" {
    for_each = var.encrypt ? [1] : []
    content {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
    }
  }
  dynamic "cors_rule" {
    for_each = length(var.cors_origins) > 0 ? [1] : []
    content {
      allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
      allowed_origins = var.cors_origins
      allowed_headers = ["*"]
    }
  }
  dynamic "website" {
    for_each = var.website != null ? [1] : []
    content {
      index_document           = lookup(var.website, "index_document", null)
      error_document           = lookup(var.website, "error_document", null)
      redirect_all_requests_to = lookup(var.website, "redirect_all_requests_to", null)
      routing_rules            = lookup(var.website, "routing_rules", null)
    }
  }
}

// If specified, attach a policy to the primary bucket
resource "aws_s3_bucket_policy" "primary" {
  count    = var.primary_bucket_policy != null ? 1 : 0
  provider = aws.primary
  bucket   = aws_s3_bucket.primary.id
  policy   = var.primary_bucket_policy
}
// If specified, attach a policy to the secondary bucket
resource "aws_s3_bucket_policy" "secondary" {
  count    = var.secondary_bucket_policy != null ? 1 : 0
  provider = aws.secondary
  bucket   = aws_s3_bucket.secondary.id
  policy   = var.secondary_bucket_policy
}
