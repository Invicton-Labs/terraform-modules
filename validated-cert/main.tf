// Create the certificate
resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain_name
  validation_method         = "DNS"
  subject_alternative_names = var.subject_alternative_names
}

// Create a record in Route53 for validating each domain on the certificate
resource "aws_route53_record" "cert-validation" {
  // 1 for the main domain name + 1 for each SAN
  count           = 1 + length(var.subject_alternative_names)
  name            = tolist(aws_acm_certificate.cert.domain_validation_options)[count.index].resource_record_name
  type            = tolist(aws_acm_certificate.cert.domain_validation_options)[count.index].resource_record_type
  zone_id         = var.route53_zone_id
  records         = [tolist(aws_acm_certificate.cert.domain_validation_options)[count.index].resource_record_value]
  ttl             = 10
  allow_overwrite = true
}

// Validate the certificate
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert-validation : record.fqdn]
}
