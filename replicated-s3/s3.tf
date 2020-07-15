resource "aws_s3_bucket" "primary" {
  provider      = aws.primary
  bucket        = local.primary_bucket_name
  acl           = var.acl
  force_destroy = var.force_destroy
  versioning {
    enabled = true
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
  acl           = var.acl
  force_destroy = var.force_destroy
  versioning {
    enabled = true
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
}
