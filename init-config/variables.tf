variable "working_dir" {
  description = "The working directory to use for determining the init configuration."
  type        = string
  default     = null
}

variable "fetch_state" {
  description = "Whether the current (pre-apply) Terraform state of this configuration should be retrieved, as provided by the `terraform_remote_state` data source. Default `false`."
  type        = bool
  default     = false
}
