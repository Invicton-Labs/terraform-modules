module "acm-certificate" {
  count  = var.acm_certificate_arn == null ? 1 : 0
  source = "../validated-acm-certificate"
  primary_domain = var.domain_to_hosted_zone_id != null ? {
    domain         = var.domain_to
    hosted_zone_id = var.domain_to_hosted_zone_id
    } : {
    domain         = keys(var.domains_from)[0]
    hosted_zone_id = var.domains_from[keys(var.domains_from)[0]]
  }
  subject_alternative_names = var.domain_to_hosted_zone_id != null ? var.domains_from : length(var.domains_from) <= 1 ? {} : { for domain in slice(keys(var.domains_from), 1, length(var.domains_from)) : domain => var.domains_from[domain] }
}

locals {
  certificate_arn = length(module.acm-certificate) == 0 ? var.acm_certificate_arn : module.acm-certificate[0].certificate_validation.certificate_arn
}

resource "random_id" "function_id" {
  byte_length = 8
}

data "archive_file" "lambda" {
  type = "zip"
  source_content = templatefile("${path.module}/origin-request/main.py", {
    redirect_path        = var.redirect_type == "KEEP_PATH" ? null : var.rewrite_path
    redirect_domain      = var.domain_to
    redirect_code        = var.redirect_code
    redirect_description = var.redirect_code == 301 ? "Moved Permanently" : "Found"
  })
  source_content_filename = "main.py"
  output_path             = var.lambda_zip_output_path != null ? var.lambda_zip_output_path : "${path.root}/lambda-domain-redirect-${random_id.function_id.hex}.zip"
}

resource "aws_s3_bucket" "origin" {
  bucket = "domain-redirect-${random_id.function_id.hex}"
  acl    = "private"
}

data "aws_iam_policy_document" "origin" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.origin.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "origin" {
  bucket = aws_s3_bucket.origin.id
  policy = data.aws_iam_policy_document.origin.json
}

resource "aws_s3_bucket_public_access_block" "origin" {
  bucket                  = aws_s3_bucket.origin.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_identity" "origin" {
  comment = "Origin access identity for domain redirect ${random_id.function_id.hex}"
}

// Create the function (and supporting resources) that are used for CloudFront origin-request responses
module "lambda-domain-redirect" {
  source                    = "../lambda-set"
  name                      = "domain-redirect-${random_id.function_id.hex}"
  edge                      = true
  archive                   = data.archive_file.lambda
  cloudwatch_retention_days = var.lambda_log_retention_days
  timeout                   = 5
  memory_size               = 128
  runtime                   = "python3.8"
  handler                   = "main.lambda_handler"
  publish                   = true
}

// Create the CloudFront distribution
resource "aws_cloudfront_distribution" "redirect" {
  // Depend on completion of the lambda so the function version is correct
  depends_on = [
    module.lambda-domain-redirect.complete
  ]

  origin {
    domain_name = aws_s3_bucket.origin.bucket_regional_domain_name
    origin_id   = "S3-Origin"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for redirecting domains."
  default_root_object = var.default_root_object

  // Configure the CloudFront logging to use the specified S3 bucket
  dynamic "logging_config" {
    for_each = var.logging_config != null ? [1] : []
    content {
      include_cookies = var.logging_config.include_cookies
      bucket          = var.logging_config.bucket
      prefix          = var.logging_config.prefix
    }
  }

  // Set the domain names for the distribution
  aliases = keys(var.domains_from)

  // Cache everything as long as possible, since they all get a redirect
  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["HEAD", "GET", "OPTIONS"]
    target_origin_id       = "S3-Origin"
    viewer_protocol_policy = "allow-all"
    min_ttl                = 31536000
    default_ttl            = 31536000
    max_ttl                = 31536000
    compress               = false

    forwarded_values {
      // Allow caching based on protocol (http vs https)
      headers      = ["CloudFront-Forwarded-Proto"]
      query_string = false
      cookies {
        forward = "none"
      }
    }

    // Link a Lambda@Edge function to return redirects for everything
    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = module.lambda-domain-redirect.lambda.qualified_arn
      include_body = false
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  // Use the TLS certificate provisioned in domain.tf
  viewer_certificate {
    acm_certificate_arn = local.certificate_arn
    ssl_support_method  = "sni-only"
  }
}

// Create a Route53 record for each domain
resource "aws_route53_record" "cloudfront-frontend" {
  for_each        = var.domains_from
  zone_id         = each.value
  name            = each.key
  type            = "A"
  allow_overwrite = false

  alias {
    name                   = aws_cloudfront_distribution.redirect.domain_name
    zone_id                = aws_cloudfront_distribution.redirect.hosted_zone_id
    evaluate_target_health = false
  }
}
