output "account" {
  description = "The subaccount resource."
  value       = aws_organizations_account.subaccount
}
output "admin_role_arn" {
  description = "The ARN of the subaccount admin role."
  value       = local.subaccount_role_arn
}
output "state_buckets" {
  description = "The S3 bucket resource on the subaccount for Terraform remote state storage."
  value = {
    primary   = module.s3-terraform-state.primary_bucket
    secondary = module.s3-terraform-state.secondary_bucket
  }
}
output "lock_table" {
  description = "The DynamoDB table resource on the subaccount for Terraform locking."
  value       = aws_dynamodb_table.terraform-state-lock
}
output "iam_user" {
  description = "An IAM user resource on the subaccount, with admin permissions (if the `create_admin_iam_user` variable was `true`)."
  value       = var.create_admin_iam_user ? aws_iam_user.terraform[0] : null
}
output "iam_key" {
  description = "An access key resource for the IAM admin user of the subaccount (if the `create_admin_iam_user` variable was `true`)."
  value       = var.create_admin_iam_user ? aws_iam_access_key.terraform[0] : null
}
output "delegation_set" {
  description = "A Route53 delegation set resource on the subaccount."
  value       = aws_route53_delegation_set.delegation
}
output "route53_hosted_zone" {
  description = "The Route53 hosted zone that was created if the 'hosted_zone_domain' variable was set."
  value       = var.hosted_zone_domain == null ? null : aws_route53_zone.zone[0]
}
