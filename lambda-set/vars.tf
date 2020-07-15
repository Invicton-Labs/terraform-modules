variable "name" {
  type = string
}
variable "edge" {
  type = bool
}
// Whether to create this Lambda function (used for optional modules that may or may not exist depending on other resources/settings)
variable "create" {
  type    = bool
  default = true
}
variable "role-policy-arns" {
  type    = list(string)
  default = []
}
variable "directory" {
  type    = string
  default = null
}
variable "archive" {
  type = object({
    output_path         = string
    output_base64sha256 = string
  })
  default = {
    output_path         = ""
    output_base64sha256 = ""
  }
}
variable "handler" {
  type    = string
  default = "main.lambda_handler"
}
variable "runtime" {
  type    = string
  default = "python3.8"
}
variable "memory_size" {
  type    = number
  default = 128
}
variable "timeout" {
  type    = number
  default = 5
}
variable "execution-services" {
  type = list(object({
    service = string
    arn     = string
  }))
  default = []
}
variable "cloudwatch_retention_days" {
  type = number
}
variable "vpc_config" {
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}
variable "environment" {
  type    = map(any)
  default = {}
}
variable "schedule" {
  type    = string
  default = null
}

locals {
  archive = var.create ? (var.archive.output_path != "" ? var.archive : {
    output_path         = data.archive_file.archive[0].output_path
    output_base64sha256 = data.archive_file.archive[0].output_base64sha256
  }) : null
}
