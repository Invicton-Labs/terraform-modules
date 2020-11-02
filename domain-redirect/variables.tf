variable "domains_from" {
  description = "A map of domain/hosted zone ID pairs to be included in the redirect. A Route53 record will be created for each one."
  type        = map(string)
  validation {
    condition     = length(var.domains_from) > 0
    error_message = "The `domains_from` variable must include at least 1 element."
  }
}

variable "domain_to" {
  description = "The domain to redirect requests to, as well as its hosted zone."
  type        = string
}

variable "domain_to_hosted_zone_id" {
  description = "The Route53 hosted zone ID of the 'to' domain (the `domain_to` variable). If provided, the 'to' domain will be included in the distribution certificate. Only used if the `acm_certificate_arn` variable is provided."
  type        = string
  default     = null
}

variable "redirect_type" {
  description = "The type of redirect to perform. Options are `KEEP_PATH` or `REWRITE_PATH`. If `REWRITE_PATH` is used, the `rewrite_path` variable must also be provided. Defaults to `KEEP_PATH`."
  type        = string
  default     = "KEEP_PATH"
  validation {
    condition     = contains(["KEEP_PATH", "REWRITE_PATH"], var.redirect_type)
    error_message = "The `redirect_type` variable must be either `KEEP_PATH` or `REWRITE_PATH`."
  }
}

variable "rewrite_path" {
  description = "The fixed, static path to redirect all requests to. It is only used if the `redirect_type` variable is set to `REWRITE_PATH`. Defaults to `/`."
  type        = string
  default     = "/"
}

variable "redirect_code" {
  description = "The HTTP code to use for the redirect. Options are `301` (moved permanently) or `302` (moved temporarily). Defaults to `302`."
  type        = number
  default     = 302
  validation {
    condition     = contains([301, 302], var.redirect_code)
    error_message = "The `redirect_code` variable must be either `301` or `302`."
  }
}

variable "lambda_log_retention_days" {
  description = "The number of days to keep the Lambda@Edge (redirect generation function) logs for. Defaults to `14`."
  type        = number
  default     = 14
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate to use for the CloudFront distribution HTTPS. If none is provided, a new one will be created with the first element of the `domains` variable as the primary domain, and all other elements of the `domains` variable as subject alternative names."
  type        = string
  default     = null
}

variable "logging_config" {
  description = "Configuration for the CloudFront distribution logging. If none is provided, logging will not be enabled."
  type = object({
    include_cookies = bool
    bucket          = string
    prefix          = string
  })
  default = null
}

variable "lambda_zip_output_path" {
  description = "The file path of the output Lambda ZIP file. Defaults to the root module path."
  type        = string
  default     = null
}

data "aws_region" "current" {}
module "assert_region" {
  source        = "../assert"
  condition     = data.aws_region.current.name == "us-east-1"
  error_message = "The AWS provider for the `domain-redirect` module must be in the 'us-east-1' region, where CloudFront distributions and Lambda@Edge functions must be created. The given provider is in the '${data.aws_region.current.name}' region."
}
