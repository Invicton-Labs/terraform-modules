output "certificate" {
  description = "The ACM certificate that was imported. Value will be null unless the 'acm_import' variable was set to 'true'."
  value       = var.acm_import ? aws_acm_certificate.cert[0] : null
}
output "private_key_pem" {
  description = "The PEM-encoded private key for the certificate."
  value       = tls_private_key.key.private_key_pem
}
output "certificate_pem" {
  description = "The PEM-encoded signed certificate."
  value       = local.cert_pem
}
