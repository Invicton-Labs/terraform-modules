resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain_name
  validation_method         = "DNS"
  subject_alternative_names = var.subject_alternative_names
}

// Create a record in Route53 for validating each SAN
resource "aws_route53_record" "cert-validation" {
  count           = 1 + length(var.subject_alternative_names)
  allow_overwrite = var.allow_overwrite
  name            = aws_acm_certificate.cert.domain_validation_options[count.index].resource_record_name
  type            = aws_acm_certificate.cert.domain_validation_options[count.index].resource_record_type
  zone_id         = var.route53_zone_id
  records         = [aws_acm_certificate.root.domain_validation_options[count.index].resource_record_value]
  ttl             = 10
}

// Validate the certificate
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert-validation : record.fqdn]
}
