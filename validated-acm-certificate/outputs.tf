output "certificate" {
  description = "The AWS ACM Certificate resource."
  value       = aws_acm_certificate.cert
}
output "route53_validation_records" {
  description = "A list of Route53 records that were used to validate the certificate."
  value       = aws_route53_record.cert-validation
}
output "certificate_validation" {
  description = "The AWS ACM Certificate Validation resource that was created to validate the certificate."
  value       = aws_acm_certificate_validation.cert
}
output "done" {
  description = "An output that is only resolved once all resources in this module have finished being created. Used for 'depends_on' fields that depend on this module."
  depends_on = [
    aws_acm_certificate.cert,
    aws_route53_record.cert-validation,
    aws_acm_certificate_validation.cert
  ]
  value = true
}
