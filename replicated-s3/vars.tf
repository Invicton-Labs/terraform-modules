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
variable "primary_acl" {
  description = "The ACL name to apply to the primary bucket. Defaults to 'private'."
  type        = string
  default     = "private"
}
variable "secondary_acl" {
  description = "The ACL name to apply to the secondary bucket. Defaults to 'private'."
  type        = string
  default     = "private"
}
variable "primary_grants" {
  description = "A list of ACL grants to apply to the primary bucket."
  type = list(object({
    id          = string
    type        = string
    permissions = list(string)
    uri         = string
  }))
  default = []
}
variable "secondary_grants" {
  description = "A list of ACL grants to apply to the secondary bucket."
  type = list(object({
    id          = string
    type        = string
    permissions = list(string)
    uri         = string
  }))
  default = []
}
variable "cloudfront_logging" {
  description = "Whether the primary bucket will be used to write CloudFront logs to. This will automatically add the required ACL to enable this."
  type        = bool
  default     = false
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
  type        = string
  default     = null
}
variable "secondary_bucket_policy" {
  description = "JSON-encoded policy to attach to the secondary bucket."
  type        = string
  default     = null
}
variable "website" {
  description = "Website configuration for S3 buckets acting as static website hosts."
  type        = map(string)
  default     = null
}
variable "public_access_block" {
  description = "Whether to block all public access to the buckets. Defaults to `true`."
  type        = bool
  default     = true
}
variable "preferred_object_ownership" {
  description = "The preferred object ownership for new objects in the buckets. Options are 'BucketOwnerPreferred' or 'ObjectWriter'."
  type = string
  default = "BucketOwnerPreferred"
}
variable "primary_tags" {
  description = "Tags to apply to the primary bucket."
  type        = map(string)
  default     = {}
}
variable "secondary_tags" {
  description = "Tags to apply to the secondary bucket."
  type        = map(string)
  default     = {}
}

data "aws_region" "primary" {
  provider = aws.primary
}
data "aws_region" "secondary" {
  provider = aws.secondary
}
module "assert_different_regions" {
  source        = "Invicton-Labs/assertion/null"
  version       = "0.1.1"
  error_message = "The 'primary' and 'secondary' providers must be in different regions."
  condition     = data.aws_region.primary.name != data.aws_region.secondary.name
}
module "assert_transition_valid" {
  source        = "Invicton-Labs/assertion/null"
  version       = "0.1.1"
  error_message = "The 'transition_days' and 'transition_class' variables must both be null, or neither be null."
  condition     = (var.transition_days == null && var.transition_class == null) || (var.transition_days != null && var.transition_class != null)
}
module "assert_noncurrent_transition_valid" {
  source        = "Invicton-Labs/assertion/null"
  version       = "0.1.1"
  error_message = "The 'noncurrent_version_transition_days' and 'noncurrent_version_transition_class' variables must both be null, or neither be null."
  condition     = (var.noncurrent_version_transition_days == null && var.noncurrent_version_transition_class == null) || (var.noncurrent_version_transition_days != null && var.noncurrent_version_transition_class != null)
}
module "assert_versioning_rules_days" {
  source        = "Invicton-Labs/assertion/null"
  version       = "0.1.1"
  error_message = "Cannot set a value for the 'noncurrent_version_transition_days' variable if the 'versioning' variable is set to false."
  condition     = var.versioning == true || var.noncurrent_version_transition_days == null
}
module "assert_versioning_rules_class" {
  source        = "Invicton-Labs/assertion/null"
  version       = "0.1.1"
  error_message = "Cannot set a value for the 'noncurrent_version_transition_class' variable if the 'versioning' variable is set to false."
  condition     = var.versioning == true || var.noncurrent_version_transition_class == null
}

locals {
  primary_bucket_name   = "${var.name_prefix}-primary${var.name_suffix != "" ? "-${var.name_suffix}" : ""}"
  secondary_bucket_name = "${var.name_prefix}-secondary${var.name_suffix != "" ? "-${var.name_suffix}" : ""}"
  primary_bucket_arn    = "arn:aws:s3:::${local.primary_bucket_name}"
  secondary_bucket_arn  = "arn:aws:s3:::${local.secondary_bucket_name}"
}
