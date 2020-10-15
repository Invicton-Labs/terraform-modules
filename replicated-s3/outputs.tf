output "primary_bucket" {
  description = "The S3 bucket resource for the primary bucket."
  value = aws_s3_bucket.primary
}
output "secondary_bucket" {
  description = "The S3 bucket resource for the secondary bucket."
  value = aws_s3_bucket.secondary
}
output "primary_bucket_policy" {
  description = "The bucket policy resource attached to the primary bucket. If the `primary_bucket_policy` variable is not provided, this will be `null`."
  value = var.primary_bucket_policy != null ? aws_s3_bucket_policy.primary[0] : null
}
output "secondary_bucket_policy" {
  description = "The bucket policy resource attached to the secondary bucket. If the `secondary_bucket_policy` variable is not provided, this will be `null`."
  value = var.secondary_bucket_policy != null ? aws_s3_bucket_policy.secondary[0] : null
}
