output "cloudfront_distribution" {
  description = "The CloudFront distribution resource that was created."
  value       = aws_cloudfront_distribution.redirect
}

output "origin_request_lambda" {
  description = "The Lambda@Edge function resource that was created for handling origin requests from the CloudFront distribution."
  value       = module.lambda-domain-redirect.lambda
}

output "acm_certificate_validation" {
  description = "The ACM certificate validation that was completed (if an ACM certificate was created)."
  value       = length(module.acm-certificate) == 0 ? null : module.acm-certificate[0].certificate_validation
}
