variable "primary_region" {
  type = string
}
variable "secondary_region" {
  type = string
}
variable "provider_profile" {
  type = string
}
variable "provider_role_to_assume" {
  type    = string
  default = null
}

variable "name_prefix" {
  type = string
}
variable "name_suffix" {
  type    = string
  default = ""
}
variable "acl" {
  type    = string
  default = "private"
}
variable "force_destroy" {
  type    = bool
  default = false
}
variable "encrypt" {
  type    = bool
  default = true
}
variable "cors_origins" {
  type    = list(string)
  default = []
}
variable "versioning" {
  type = bool
}
variable "transition_days" {
  type    = number
  default = null
}
variable "transition_class" {
  type    = string
  default = null
}
variable "noncurrent_version_transition_days" {
  type    = number
  default = null
}
variable "noncurrent_version_transition_class" {
  type    = string
  default = null
}

locals {
  assert_transition_valid            = (var.transition_days != null && var.transition_class == null) || (var.transition_days == null && var.transition_class != null) ? file("ERROR: transition_days and transition_class must both be null, or neither be null") : null
  assert_noncurrent_transition_valid = (var.noncurrent_version_transition_days != null && var.noncurrent_version_transition_class == null) || (var.noncurrent_version_transition_days == null && var.noncurrent_version_transition_class != null) ? file("ERROR: noncurrent_version_transition_days and noncurrent_version_transition_class must both be null, or neither be null") : null
  assert_versioning_rules            = var.versioning == false && var.noncurrent_version_transition_days != null ? file("ERROR: cannot set a value for noncurrent_version_transition_days if versioning is set to false") : null
  primary_bucket_name                = "${var.name_prefix}-primary${var.name_suffix != "" ? "-${var.name_suffix}" : ""}"
  secondary_bucket_name              = "${var.name_prefix}-secondary${var.name_suffix != "" ? "-${var.name_suffix}" : ""}"
  primary_bucket_arn                 = "arn:aws:s3:::${local.primary_bucket_name}"
  secondary_bucket_arn               = "arn:aws:s3:::${local.secondary_bucket_name}"
}
