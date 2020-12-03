variable "api_id" {
  description = "The API ID for the GraphQL API for the DataSource."
  type        = string
}

variable "name" {
  description = "A user-supplied name for the DataSource."
  type        = string
}

variable "type" {
  description = "The type of the DataSource. Valid values: `RELATIONAL_DATABASE`."
  type        = string
  validation {
    condition     = var.type == "RELATIONAL_DATABASE"
    error_message = "The only acceptable value for the `type` variable is `RELATIONAL_DATABASE`."
  }
}

variable "description" {
  description = "A description of the DataSource."
  type        = string
  default     = null
}

variable "service_role_arn" {
  description = "The IAM service role ARN for the data source."
  type        = string
  default     = null
}

variable "aws_region" {
  description = "AWS Region for RDS HTTP endpoint."
  type        = string
}

variable "aws_secret_store_arn" {
  description = "AWS secret store ARN for database credentials."
  type        = string
}

variable "database_cluster_arn" {
  description = "Amazon RDS cluster ARN."
  type        = string
}

variable "database_name" {
  description = "Logical database name."
  type        = string
  default     = null
}

variable "schema" {
  description = "Logical schema name."
  type        = string
  default     = null
}
