variable "route53_zone_id" {
  description = "The ID of the Route53 zone that the validation record should be created in."
  type        = string
}
variable "domain_name" {
  description = "The primary certificate domain name."
  type        = string
}
variable "subject_alternative_names" {
  description = "A list of subject alternative names to include in the certificate. Defaults to an empty list ([])."
  type        = list(string)
  default     = []
}
