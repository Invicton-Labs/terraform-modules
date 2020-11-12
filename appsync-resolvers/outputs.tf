output "functions" {
  description = "A map of AppSync function resources that were created. The map keys correspond to the map keys in the `functions` input variable."
  value       = aws_appsync_function.functions
}
output "unit_resolvers" {
  description = "A map of AppSync unit resolver resources that were created. The map keys correspond to the map keys in the `unit_resolvers` input variable."
  value       = aws_appsync_resolver.pipelines
}
output "pipeline_resolvers" {
  description = "A map of AppSync pipeline resolver resources that were created. The map keys correspond to the map keys in the `pipeline_resolvers` input variable."
  value       = aws_appsync_resolver.pipelines
}
