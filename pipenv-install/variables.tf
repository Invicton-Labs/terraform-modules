variable "working_dir" {
  description = "The path to the directory containing the Pip project."
  type        = string
}

variable "create_archive" {
  description = "Whether to create an archive with the source and dependencies. Default `false`."
  type        = bool
  default     = false
}

variable "archive_file" {
  description = "The filename (with path) for the packed ZIP archive. Defaults to the parent directory of the working directory."
  type        = string
  default     = null
}

variable "suppress_non_existance_error" {
  description = "Whether to suppress the error that would be thrown if no Pipfile exists in the project directory. Useful for using this module in projects that do not yet have any dependencies, but might in the future. Default `false`."
  type        = bool
  default     = false
}

variable "require_piplock" {
  description = "Whether a Pipfile.lock file is required. Useful for ensuring that known versions of every dependency are being installed. Default `true`."
  type        = bool
  default     = true
}
