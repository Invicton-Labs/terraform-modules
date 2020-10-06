variable "functions_path" {
  description = "Filesystem path to the directory that contains the AppSync functions. Within this directory are directories with names corresponding to the names of each datasource. Within each datasource directory are directories with names corresponding to the names of each function. Within each function directory are two files: `request.vtl` and `response.vtl`, containing the request mapping templates and response mapping templates, respectively."
  type        = string
  default     = null
}
variable "unit_resolvers_path" {
  description = "Filesystem path to the directory that contains the AppSync unit resolvers. Within this directory are directories with names corresponding to the names of each datasource. Within each datasource directory are directories with names corresponding to the resolver type (e.g. `Query`, `Mutation`). Within each type directory are directories with names corresponding to the names of each unit resolver. Within each unit resolver directory are two files: `request.vtl` and `response.vtl`, containing the request mapping templates and response mapping templates, respectively."
  type        = string
  default     = null
}
variable "pipeline_resolvers_path" {
  description = "Filesystem path to the directory that contains the AppSync pipeline resolvers. Within this directory are directories with names corresponding to the resolver type (e.g. `Query`, `Mutation`). Within each type directory are directories with names corresponding to the names of each pipeline resolver. Within each pipeline resolver there are three files: `request.vtl`, `response.vtl`, and `functions.txt`, containing the request mapping templates, response mapping templates, and functions list, respectively. The functions list consists of a list of function keys in the format of `DatasourceName/FunctionName` (matching the directory structure of the corresponding function)."
  type        = string
  default     = null
}
