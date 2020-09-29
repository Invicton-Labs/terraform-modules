// Create a private key for the cert
resource "tls_private_key" "key" {
  algorithm   = var.key_algorithm
  rsa_bits    = var.key_bits
  ecdsa_curve = var.key_algorithm == "ECDSA" ? var.ecdsa_curve : null
}

// If no CA was provided, create a self-signed cert
resource "tls_self_signed_cert" "cert" {
  count           = var.certificate_authority == null ? 1 : 0
  key_algorithm   = var.key_algorithm
  private_key_pem = tls_private_key.key.private_key_pem
  subject {
    common_name         = var.subject_common_name
    organization        = var.subject_organization
    organizational_unit = var.subject_organizational_unit
    street_address      = var.subject_street_address
    locality            = var.subject_locality
    province            = var.subject_province
    country             = var.subject_country
    postal_code         = var.subject_postal_code
    serial_number       = var.subject_serial_number
  }
  validity_period_hours = var.validity_period_hours
  allowed_uses          = var.allowed_uses
  dns_names             = var.dns_names
  ip_addresses          = var.ip_addresses
  uris                  = var.uris
  early_renewal_hours   = var.early_renewal_hours
  is_ca_certificate     = var.is_ca_certificate
  set_subject_key_id    = var.set_subject_key_id
}

// If a CA was provided, create a certificate request
resource "tls_cert_request" "cert" {
  count           = var.certificate_authority != null ? 1 : 0
  key_algorithm   = var.key_algorithm
  private_key_pem = tls_private_key.key.private_key_pem
  subject {
    common_name         = var.subject_common_name
    organization        = var.subject_organization
    organizational_unit = var.subject_organizational_unit
    street_address      = var.subject_street_address
    locality            = var.subject_locality
    province            = var.subject_province
    country             = var.subject_country
    postal_code         = var.subject_postal_code
    serial_number       = var.subject_serial_number
  }
  dns_names    = var.dns_names
  ip_addresses = var.ip_addresses
  uris         = var.uris
}

// If a CA was provided, sign the certificate request
resource "tls_locally_signed_cert" "cert" {
  count                 = var.certificate_authority != null ? 1 : 0
  cert_request_pem      = tls_cert_request.cert[0].cert_request_pem
  ca_key_algorithm      = var.certificate_authority.private_key_algorithm
  ca_private_key_pem    = var.certificate_authority.private_key_pem
  ca_cert_pem           = var.certificate_authority.cert_pem
  validity_period_hours = var.validity_period_hours
  allowed_uses          = var.allowed_uses
  early_renewal_hours   = var.early_renewal_hours
  is_ca_certificate     = var.is_ca_certificate
  set_subject_key_id    = var.set_subject_key_id
}

locals {
  cert_pem              = var.certificate_authority == null ? tls_self_signed_cert.cert[0].cert_pem : tls_locally_signed_cert.cert[0].cert_pem
  certificate_chain_pem = var.certificate_authority == null ? null : var.certificate_authority.cert_pem
}

// Import the cert into ACM
resource "aws_acm_certificate" "cert" {
  count             = var.acm_import ? 1 : 0
  private_key       = tls_private_key.key.private_key_pem
  certificate_body  = local.cert_pem
  certificate_chain = local.certificate_chain_pem
  tags = {
    Name = var.certificate_acm_name != null ? var.certificate_acm_name : var.subject_common_name
  }
}
