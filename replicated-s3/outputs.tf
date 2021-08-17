output "primary_bucket_name" {
  description = "The name of the primary S3 bucket that will be created. Unlike the `primary_bucket` output, this output is available prior to apply."
  value       = local.primary_bucket_name
}
output "secondary_bucket_name" {
  description = "The name of the secondary S3 bucket that will be created. Unlike the `primary_bucket` output, this output is available prior to apply."
  value       = local.secondary_bucket_name
}
output "primary_bucket_arn" {
  description = "The ARN of the primary S3 bucket that will be created. Unlike the `primary_bucket` output, this output is available prior to apply."
  value       = "arn:aws:s3:::${local.primary_bucket_name}"
}
output "secondary_bucket_arn" {
  description = "The ARN of the secondary S3 bucket that will be created. Unlike the `primary_bucket` output, this output is available prior to apply."
  value       = "arn:aws:s3:::${local.secondary_bucket_name}"
}
output "primary_bucket" {
  description = "The S3 bucket resource for the primary bucket."
  value       = aws_s3_bucket.primary
}
output "secondary_bucket" {
  description = "The S3 bucket resource for the secondary bucket."
  value       = aws_s3_bucket.secondary
}
output "primary_bucket_policy" {
  description = "The bucket policy resource attached to the primary bucket. If the `primary_bucket_policy` variable is not provided, this will be `null`."
  value       = var.primary_bucket_policy != null ? aws_s3_bucket_policy.primary[0] : null
}
output "secondary_bucket_policy" {
  description = "The bucket policy resource attached to the secondary bucket. If the `secondary_bucket_policy` variable is not provided, this will be `null`."
  value       = var.secondary_bucket_policy != null ? aws_s3_bucket_policy.secondary[0] : null
}
output "complete" {
  description = "A flag for determining when everything in this module has been created."
  depends_on = [
    aws_iam_role_policy.replication,
    aws_s3_bucket.primary,
    aws_s3_bucket.secondary,
    aws_s3_bucket_policy.primary,
    aws_s3_bucket_policy.secondary,
    aws_s3_bucket_public_access_block.primary,
    aws_s3_bucket_public_access_block.secondary,
    aws_s3_bucket_ownership_controls.primary,
    aws_s3_bucket_ownership_controls.secondary,
  ]
  value = true
}
