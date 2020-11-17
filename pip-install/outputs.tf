output "archive" {
  description = "The packed ZIP archive resource. `null` if the `create_archive` variable wasn't provided."
  value       = length(data.archive_file.archive) > 0 ? data.archive_file.archive[0] : null
}
