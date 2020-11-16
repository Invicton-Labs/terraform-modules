variable "working_dir" {
  description = "The path to the directory containing the Pip project."
  type        = string
}

variable "python_version" {
  description = "The version of Python to use, e.g. `3.8`."
  type        = string
}

variable "create_archive" {
  description = "Whether to create an archive with the source and dependencies. Defaults to `false`."
  type        = bool
  default     = false
}

variable "requirements_file" {
  description = "The name of the requirements file. Defaults to `requirements.txt`."
  type        = string
  default     = "requirements.txt"
}


variable "platform" {
  description = "The platform to install Pip packages for (same options as `pip install`'s `--platform` option). Defaults to `linux_x86_64`."
  type        = string
  default     = "linux_x86_64"
}

variable "archive_file" {
  description = "The filename (with path) for the packed ZIP archive. Defaults to the parent directory of the working directory."
  type        = string
  default     = null
}

variable "suppress_non_existance_error" {
  description = "Whether to suppress the error that would be thrown if no requirements.txt exists in the project directory. Useful for using this module in projects that do not yet have any dependencies, but might in the future. Default `false`."
  type        = bool
  default     = false
}
