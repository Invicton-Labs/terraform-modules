variable "name" {
  description = "The name of the subaccount."
  type        = string
}
variable "email" {
  description = "The email address to use for the subaccount's root user."
  type        = string
}
variable "region" {
  description = "The region to deploy subaccount resources in (e.g. S3 bucket for state)."
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
