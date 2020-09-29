variable "certificate_authority" {
  description = "The Certificate Authority certificate to use for signing the new certificate."
  type = object({
    private_key_algorithm = string
    private_key_pem       = string
    cert_pem              = string
  })
  default = null
}
variable "acm_import" {
  description = "Boolean value of whether the generated and signed certificate should be imported into ACM. Defaults to false."
  type        = bool
  default     = false
}
variable "key_algorithm" {
  description = "Algorithm to use for the private key. Options are 'RSA' or 'ECDSA'. Defaults to 'RSA'."
  type        = string
  default     = "RSA"
}
variable "ecdsa_curve" {
  description = "Elliptic curve to use for the ECDSA algorithm. Has no effect unless the 'key_algorithm' variable is set to 'ECDSA'. Options are 'P224', 'P256', 'P384', or 'P521'. Defaults to 'P224'."
  type        = string
  default     = "P224"
}
variable "key_bits" {
  description = "Number of bits to use for the RSA private key. Defaults to 2048."
  type        = number
  default     = 2048
}
variable "certificate_acm_name" {
  description = "The name to display for the certificate in ACM. Defaults to the subject common name."
  type        = string
  default     = null
}
variable "subject_common_name" {
  description = "The certificate subject's common name."
  type        = string
}
variable "subject_organization" {
  description = "The certificate subject's organization."
  type        = string
  default     = null
}
variable "subject_organizational_unit" {
  description = "The certificate subject's organizational unit."
  type        = string
  default     = null
}
variable "subject_street_address" {
  description = "The certificate subject's street address (list of strings)."
  type        = list(string)
  default     = null
}
variable "subject_locality" {
  description = "The certificate subject's locality."
  type        = string
  default     = null
}
variable "subject_province" {
  description = "The certificate subject's province."
  type        = string
  default     = null
}
variable "subject_country" {
  description = "The certificate subject's country."
  type        = string
  default     = null
}
variable "subject_postal_code" {
  description = "The certificate subject's postal code."
  type        = string
  default     = null
}
variable "subject_serial_number" {
  description = "The certificate subject's serial number."
  type        = string
  default     = null
}
variable "validity_period_hours" {
  description = "How many hours the certificate should be valid for. Defaults to 8760 (1 year)."
  type        = number
  default     = 8760
}
variable "dns_names" {
  description = "List of DNS names for which a certificate is being created. Defaults to none."
  type        = list(string)
  default     = null
}
variable "ip_addresses" {
  description = "List of IP addresses for which a certificate is being created. Defaults to none."
  type        = list(string)
  default     = null
}
variable "uris" {
  description = "List of URIs for which a certificate is being created. Defaults to none."
  type        = list(string)
  default     = null
}
variable "early_renewal_hours" {
  description = "If set, the resource will consider the certificate to have expired the given number of hours before its actual expiry time. This can be useful to deploy an updated certificate in advance of the expiration of the current certificate. Note however that the old certificate remains valid until its true expiration time, since this resource does not (and cannot) support certificate revocation. Note also that this advance update can only be performed should the Terraform configuration be applied during the early renewal period."
  type        = number
  default     = null
}
variable "is_ca_certificate" {
  description = "Boolean controlling whether the CA flag will be set in the generated certificate. Defaults to false, meaning that the certificate does not represent a certificate authority."
  type        = bool
  default     = false
}
variable "set_subject_key_id" {
  description = "If true, the certificate will include the subject key identifier. Defaults to false, in which case the subject key identifier is not set at all."
  type        = bool
  default     = false
}
variable "allowed_uses" {
  description = "List of keywords each describing a use that is permitted for the issued certificate, combining the set of flags defined by both Key Usage and Extended Key Usage in RFC5280. Options are: digital_signature, content_commitment, key_encipherment, data_encipherment, key_agreement, cert_signing, crl_signing, encipher_only, decipher_only, any_extended, server_auth, client_auth, code_signing, email_protection, ipsec_end_system, ipsec_tunnel, ipsec_user, timestamping, ocsp_signing, microsoft_server_gated_crypto, netscape_server_gated_crypto. Defaults to allow all of them."
  type        = list(string)
  default = [
    "digital_signature",
    "content_commitment",
    "key_encipherment",
    "data_encipherment",
    "key_agreement",
    "cert_signing",
    "crl_signing",
    "encipher_only",
    "decipher_only",
    "any_extended",
    "server_auth",
    "client_auth",
    "code_signing",
    "email_protection",
    "ipsec_end_system",
    "ipsec_tunnel",
    "ipsec_user",
    "timestamping",
    "ocsp_signing",
    "microsoft_server_gated_crypto",
    "netscape_server_gated_crypto"
  ]
}
