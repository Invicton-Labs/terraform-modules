variable "api_id" {
  description = "The ID of the AppSync API to manage resolvers for."
  type        = string
}
variable "datasources" {
  description = "A list of AppSync datasource resources (`aws_appsync_datasource` resource objects). This list must contain all datasource resources that are used by any functions in the `functions` input variable or any unit resolvers in the `unit_resolvers` input variable."
  type = list(object({
    api_id = string
    name   = string
    type   = string
    arn    = string
  }))
  default = []
}
variable "functions" {
  description = "A map of key-map pairs of AppSync functions. The keys are only used for unique identification (e.g. a combination of datasource name and function name). The values are maps themselves."
  type = map(object({
    name                      = string
    datasource_name           = string
    request_mapping_template  = string
    response_mapping_template = string
  }))
  default = {}
}
variable "unit_resolvers" {
  description = "A map of key-map pairs of AppSync unit resolvers. The keys are only used for unique identification (e.g. a combination of datasource name and resolver name). The values are maps themselves."
  type = map(object({
    name                      = string
    type                      = string
    datasource_name           = string
    request_mapping_template  = string
    response_mapping_template = string
  }))
  default = {}
}
variable "pipeline_resolvers" {
  description = "A map of key-map pairs of AppSync pipeline resolvers. The keys are only used for unique identification (e.g. a combination of datasource name and resolver name). The values are maps themselves. The 'functions' field within the value map is a list of function keys, corresponding with the map keys provided for the 'functions' variable."
  type = map(object({
    name                      = string
    type                      = string
    request_mapping_template  = string
    response_mapping_template = string
    functions                 = list(string)
  }))
  default = {}
}

locals {
  function_datasources = distinct([
    for function in var.functions :
    function.datasource_name
  ])
  unit_datasources = distinct([
    for unit in var.unit_resolvers :
    unit.datasource_name
  ])
  provided_datasource_map = {
    for datasource in var.datasources :
    datasource.name => datasource
  }
  datasource_names          = distinct(concat(local.function_datasources, local.unit_datasources))
  provided_datasource_names = keys(local.provided_datasource_map)
}

module "assert_datasources_exist" {
  for_each      = toset(local.datasource_names)
  depends_on    = [var.datasources]
  source        = "../assert"
  error_message = "Datasource `${each.value}` is referred to in a function or unit resolver, but was not provided in the `datasources` variable ([${join(", ", local.provided_datasource_names)}])."
  condition     = contains(local.provided_datasource_names, each.value)
}
