variable "scripts" {
  description = "A map of Python scripts to run (keys as script names for access results)."
  type        = map(string)
}

variable "lambda_zip_output_path" {
  description = "The file path of the output Lambda ZIP file. Defaults to the root module path."
  type        = string
  default     = null
}
