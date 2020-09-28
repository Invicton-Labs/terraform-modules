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
