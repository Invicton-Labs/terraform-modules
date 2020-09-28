output "account" {
  description = "The subaccount resource."
  value       = aws_organizations_account.subaccount
}
output "admin_role_arn" {
  description = "The ARN of the subaccount admin role."
  value       = local.subaccount_role_arn
}
output "state_bucket" {
  description = "The S3 bucket resource on the subaccount for Terraform remote state storage."
  value       = aws_s3_bucket.terraform_state
}
output "lock_table" {
  description = "The DynamoDB table resource on the subaccount for Terraform locking."
  value       = aws_dynamodb_table.terraform-state-lock
}
output "iam_user" {
  description = "An IAM user resource on the subaccount, with admin permissions."
  value       = aws_iam_user.terraform
}
output "iam_key" {
  description = "An access key resource for the IAM admin user of the subaccount."
  value       = aws_iam_access_key.terraform
}
output "delegation_set" {
  description = " A Route53 delegation set resource on the subaccount."
  value       = aws_route53_delegation_set.delegation
}
