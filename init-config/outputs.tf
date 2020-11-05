output "initialized" {
  description = "Whether Terraform initialization has been completed"
  value       = local.init_found
}

output "backend_configured" {
  description = "Whether a backend has been configured"
  value       = local.backend_configured
}

output "backend" {
  description = "The backend configuration"
  value       = local.backend
}

output "workspace" {
  description = "The currently active workspace (`null` if none configured/selected)."
  value       = local.workspace
}

output "state" {
  description = "The current (pre-apply) Terraform state of this configuration, as provided by the `terraform_remote_state` data source. If no backend is configured or the `fetch_state` variable is set to `false`, this value will be `null`."
  value       = length(data.terraform_remote_state.state) > 0 ? data.terraform_remote_state.state[0].outputs : null
}
