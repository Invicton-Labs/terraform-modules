// This section has been replaced with accepting provider proxies from the caller
/*
variable "primary_region" {
  description = "The region of the primary bucket."
  type        = string
}
variable "secondary_region" {
  description = "The region of the secondary (replicated) bucket."
  type        = string
}
variable "provider_profile" {
  description = "The AWS credentials profile to use for the primary and secondary region providers. Mutually exclusive with the 'provider_access_key_id' and 'provider_access_key_secret' variables."
  type        = string
  default     = null
}
variable "provider_access_key_id" {
  description = "The AWS IAM access key ID to use for the primary and secondary region providers. Mutually exclusive with the 'provider_profile' variable."
  type        = string
  default     = null
}
variable "provider_access_key_secret" {
  description = "The AWS IAM access key secret to use for the primary and secondary region providers. Mutually exclusive with the 'provider_profile' variable."
  type        = string
  default     = null
}
variable "provider_role_to_assume" {
  description = "The IAM role to assume for the primary and secondary region providers. Defaults to none."
  type        = string
  default     = null
}
*/
variable "name_prefix" {
  description = "The prefix part of the bucket name. The complete bucket name will be '{name_prefix}_{primary/secondary}_{name_suffix}'."
  type        = string
}
variable "name_suffix" {
  description = "The suffix part of the bucket name. The complete bucket name will be '{name_prefix}_{primary/secondary}_{name_suffix}'. Defaults to an empty string (no suffix)."
  type        = string
  default     = ""
}
variable "versioning" {
  description = "Whether objects in the buckets should be versioned. If set to 'false', versioning will still be configured on the buckets (since it is required for replication), but non-current versions of objects will be automatically deleted as soon as possible."
  type        = bool
}
variable "acl" {
  description = "The ACL name to apply to the buckets. Defaults to 'private'."
  type        = string
  default     = "private"
}
variable "force_destroy" {
  description = "Whether buckets should be destroyed if configuration changes. Defaults to 'false'."
  type        = bool
  default     = false
}
variable "encrypt" {
  description = "Whether bucket contents should be encrypted. Defaults to 'true'."
  type        = bool
  default     = true
}
variable "cors_origins" {
  description = "A list of origins to allow for CORS. Defaults to an empty list."
  type        = list(string)
  default     = []
}
variable "transition_days" {
  description = "The number of days before objects in the buckets should be transitioned to a different storage class."
  type        = number
  default     = null
}
variable "transition_class" {
  description = "The storage class that objects in the buckets should be transitioned to."
  type        = string
  default     = null
}
variable "noncurrent_version_transition_days" {
  description = "The number of days before non-current versions of objects in the buckets should be transitioned to a different storage class. Only applicable if the 'versioning' variable is set to 'true'."
  type        = number
  default     = null
}
variable "noncurrent_version_transition_class" {
  description = "The storage class that non-current versions of objects in the buckets should be transitioned to. Only applicable if the 'versioning' variable is set to 'true'."
  type        = string
  default     = null
}
variable "primary_bucket_policy" {
  description = "JSON-encoded policy to attach to the primary bucket."
  type = string
  default = null
}
variable "secondary_bucket_policy" {
  description = "JSON-encoded policy to attach to the secondary bucket."
  type = string
  default = null
}

data "aws_region" "primary" {
  provider = aws.primary
}
data "aws_region" "secondary" {
  provider = aws.secondary
}

module "assert_different_regions" {
  source        = "../assert"
  error_message = "The 'primary' and 'secondary' providers must be in different regions."
  condition     = data.aws_region.primary.name != data.aws_region.secondary.name
}
module "assert_transition_valid" {
  source        = "../assert"
  error_message = "The 'transition_days' and 'transition_class' variables must both be null, or neither be null."
  condition     = (var.transition_days == null && var.transition_class == null) || (var.transition_days != null && var.transition_class != null)
}
module "assert_noncurrent_transition_valid" {
  source        = "../assert"
  error_message = "The 'noncurrent_version_transition_days' and 'noncurrent_version_transition_class' variables must both be null, or neither be null."
  condition     = (var.noncurrent_version_transition_days == null && var.noncurrent_version_transition_class == null) || (var.noncurrent_version_transition_days != null && var.noncurrent_version_transition_class != null)
}
module "assert_versioning_rules_days" {
  source        = "../assert"
  error_message = "Cannot set a value for the 'noncurrent_version_transition_days' variable if the 'versioning' variable is set to false."
  condition     = var.versioning == true || var.noncurrent_version_transition_days == null
}
module "assert_versioning_rules_class" {
  source        = "../assert"
  error_message = "Cannot set a value for the 'noncurrent_version_transition_class' variable if the 'versioning' variable is set to false."
  condition     = var.versioning == true || var.noncurrent_version_transition_class == null
}

locals {
  primary_bucket_name   = "${var.name_prefix}-primary${var.name_suffix != "" ? "-${var.name_suffix}" : ""}"
  secondary_bucket_name = "${var.name_prefix}-secondary${var.name_suffix != "" ? "-${var.name_suffix}" : ""}"
  primary_bucket_arn    = "arn:aws:s3:::${local.primary_bucket_name}"
  secondary_bucket_arn  = "arn:aws:s3:::${local.secondary_bucket_name}"
}
