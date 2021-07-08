variable "primary_domain" {
  description = "The domain name and hosted zone ID of the primary certificate domain name."
  type = object({
    domain         = string
    hosted_zone_id = string
  })
}
variable "subject_alternative_names" {
  description = "A map of domain/hosted zone ID pairs of subject alternative names to include in the certificate. Defaults to an empty map ({})."
  type        = map(string)
  default     = {}
}
