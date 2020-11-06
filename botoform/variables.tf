variable "scripts" {
  description = "A map of lists of scripts to run (keys as script names for access results). Each element in each of the list is a map containing an `interpreter` (e.g `python3` or `bash`), the `code` (will be stored in a file and executed by the `interpreter`), and a boolean value for `allow_nonzero_exit` (whether Terraform should accept an execution that returns a non-zero exit code)."
  type = map(object({
    triggers = map(string)
    scripts = list(object({
      interpreter        = string
      code               = string
      allow_nonzero_exit = bool
    }))
  }))
}

variable "lambda_zip_output_path" {
  description = "The file path of the output Lambda ZIP file. Defaults to the module's base path."
  type        = string
  default     = null
}

variable "timeout" {
  description = "The Lambda function timeout."
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "The memory size of the Lambda function."
  type        = number
  default     = 128
}
