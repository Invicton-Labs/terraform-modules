output "api_id" {
  description = "The API ID for the GraphQL API for the DataSource."
  value       = aws_cloudformation_stack.datasource.parameters.ApiId
}

output "type" {
  description = "The type of the DataSource. Valid values: `RELATIONAL_DATABASE`."
  depends_on  = [aws_cloudformation_stack.datasource]
  value       = var.type
}

output "description" {
  description = "A description of the DataSource."
  value       = aws_cloudformation_stack.datasource.parameters.Description
}

output "service_role_arn" {
  description = "The IAM service role ARN for the data source."
  value       = aws_cloudformation_stack.datasource.parameters.ServiceRoleArn
}

output "aws_region" {
  description = "AWS Region for RDS HTTP endpoint."
  value       = aws_cloudformation_stack.datasource.parameters.AwsRegion
}

output "aws_secret_store_arn" {
  description = "AWS secret store ARN for database credentials."
  value       = aws_cloudformation_stack.datasource.parameters.AwsSecretStoreArn
}

output "database_cluster_arn" {
  description = "Amazon RDS cluster ARN."
  value       = aws_cloudformation_stack.datasource.parameters.DbClusterIdentifier
}

output "database_name" {
  description = "Logical database name."
  value       = lookup(aws_cloudformation_stack.datasource.parameters, "DatabaseName", null)
}

output "schema" {
  description = "Logical schema name."
  value       = lookup(aws_cloudformation_stack.datasource.parameters, "Schema", null)
}

output "name" {
  description = "A user-supplied name for the DataSource."
  depends_on  = [aws_cloudformation_stack.datasource]
  value       = aws_cloudformation_stack.datasource.outputs.Name
}

output "arn" {
  description = "The ARN of the datasource."
  depends_on  = [aws_cloudformation_stack.datasource]
  value       = aws_cloudformation_stack.datasource.outputs.Arn
}

