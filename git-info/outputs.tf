output "is_git" {
  description = "Whether the directory is a Git repository."
  value       = local.is_git
}
output "remote_url" {
  description = "The remote URL for this Git repository. `null` if it's not a Git repository."
  value       = local.is_git ? data.external.info.result.remote : null
}
output "branch" {
  description = "The branch that is currently checked out. `null` if it's not a Git repository."
  value       = local.is_git ? data.external.info.result.branch : null
}
output "commit_hash" {
  description = "The commit hash that is currently checked out. `null` if it's not a Git repository."
  value       = local.is_git ? data.external.info.result.hash : null
}
