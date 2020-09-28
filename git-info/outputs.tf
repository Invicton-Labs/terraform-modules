output "remote_url" {
  description = "The remote URL for this Git repository."
  value       = data.external.info.result.remote
}
output "branch" {
  description = "The branch that is currently checked out."
  value       = data.external.info.result.branch
}
output "commit_hash" {
  description = "The commit hash that is currently checked out."
  value       = data.external.info.result.hash
}
