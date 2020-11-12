// Create the functions that can be used in pipelines
resource "aws_appsync_function" "functions" {
  for_each                  = var.functions
  depends_on                = [var.datasources]
  api_id                    = var.api_id
  data_source               = each.value.datasource_name
  name                      = each.value.name
  request_mapping_template  = each.value.request_mapping_template == "" ? " " : each.value.request_mapping_template
  response_mapping_template = each.value.response_mapping_template == "" ? " " : each.value.response_mapping_template
}

// Create the unit resolvers
resource "aws_appsync_resolver" "unit" {
  for_each          = var.unit_resolvers
  depends_on        = [var.datasources]
  api_id            = var.api_id
  type              = each.value.type
  field             = each.value.name
  data_source       = each.value.datasource_name
  request_template  = each.value.request_mapping_template == "" ? " " : each.value.request_mapping_template
  response_template = each.value.response_mapping_template == "" ? " " : each.value.response_mapping_template
  kind              = "UNIT"
}

// Create the pipeline resolvers
resource "aws_appsync_resolver" "pipelines" {
  for_each          = var.pipeline_resolvers
  api_id            = var.api_id
  type              = each.value.type
  field             = each.value.name
  request_template  = each.value.request_mapping_template == "" ? " " : each.value.request_mapping_template
  response_template = each.value.response_mapping_template == "" ? " " : each.value.response_mapping_template
  kind              = "PIPELINE"
  pipeline_config {
    functions = [
      for function in each.value.functions :
      aws_appsync_function.functions[function].function_id
    ]
  }
}
