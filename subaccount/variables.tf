variable "name" {
  description = "The name of the subaccount."
  type        = string
}
variable "email" {
  description = "The email address to use for the subaccount's root user."
  type        = string
}
variable "region_primary" {
  description = "The primary region to deploy subaccount resources in (e.g. S3 bucket for state)."
  type        = string
}
variable "region_secondary" {
  description = "The secondary region to deploy subaccount resources in (e.g. replicated S3 bucket for state)."
  type        = string
}
variable "aws_profile" {
  description = "The name of the profile to use for the subaccount provider."
  type        = string
  default     = null
}
variable "billing_access" {
  description = "Whether IAM users on this account should have access to billing info."
  type        = bool
  default     = false
}
variable "role_name" {
  description = "The name of an admin role to create (can be assumed by parent account users)."
  type        = string
  default     = "SubAdmin"
}
variable "parent_id" {
  description = "The ID of the subaccount's parent (Parent Organizational Unit ID or Root ID)."
  type        = string
  default     = null
}
variable "pgp_key" {
  description = "An optional PGP key for encrypting the IAM access key."
  type        = string
  default     = null
}
variable "hosted_zone_domain" {
  description = "An optional domain to create a hosted zone for on the subaccount."
  type        = string
  default     = null
}
variable "hosted_zone_records" {
  description = "An optional list of Route53 records to create on the optional Route53 hosted zone. Only used if the 'hosted_zone_domain' variable is provided."
  type = list(object({
    name    = string
    type    = string
    ttl     = number
    records = list(string)
  }))
  default = []
}
variable "config_map" {
  description = "An optional map of configuration values to store in the subaccount."
  type        = any
  default     = {}
  validation {
    condition     = try(tonumber(var.config_map), tobool(var.config_map), tostring(var.config_map), tolist(var.config_map), null) == null
    error_message = "The `config_map` variable must be a a map/object."
  }
}
