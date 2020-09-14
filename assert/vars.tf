variable "error_message" {
  type = string
}

variable "condition" {
  type = bool
}

data "external" "assertion" {
  count   = var.condition ? 0 : 1
  program = ["ERROR: ${var.error_message}"]
}
