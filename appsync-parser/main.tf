locals {
  // Gives "/" on Unix, "\" on Windows
  path_separator = dirname("/")

  function_paths = distinct([
    for file in var.functions_path == null ? [] : fileset(var.functions_path, "*/*/*") :
    dirname(file)
  ])
  function_info = {
    for function_path in local.function_paths :
    function_path => {
      datasource_name           = split(local.path_separator, function_path)[0]
      name                      = split(local.path_separator, function_path)[1]
      request_mapping_template  = file("${var.functions_path}/${function_path}/request.vtl")
      response_mapping_template = file("${var.functions_path}/${function_path}/response.vtl")
    }
  }
  functions = {
    for function in local.function_info :
    "${function.datasource_name}/${function.name}" => {
      name                      = function.name
      datasource_name           = function.datasource_name
      request_mapping_template  = function.request_mapping_template == "" ? " " : function.request_mapping_template
      response_mapping_template = function.response_mapping_template == "" ? " " : function.response_mapping_template
    }
  }

  // Unit resolvers
  unit_resolver_paths = distinct([
    for file in var.unit_resolvers_path == null ? [] : fileset(var.unit_resolvers_path, "*/*/*/*") :
    dirname(file)
  ])
  unit_resolver_info = {
    for resolver_path in local.unit_resolver_paths :
    resolver_path => {
      datasource_name           = split(local.path_separator, resolver_path)[0]
      type                      = split(local.path_separator, resolver_path)[1]
      name                      = split(local.path_separator, resolver_path)[2]
      request_mapping_template  = file("${var.unit_resolvers_path}/${resolver_path}/request.vtl")
      response_mapping_template = file("${var.unit_resolvers_path}/${resolver_path}/response.vtl")
    }
  }
  unit_resolvers = {
    for resolver in local.unit_resolver_info :
    "${resolver.datasource_name}/${resolver.type}/${resolver.name}" => {
      type                      = resolver.type
      name                      = resolver.name
      datasource_name           = resolver.datasource_name
      request_mapping_template  = resolver.request_mapping_template == "" ? " " : resolver.request_mapping_template
      response_mapping_template = resolver.response_mapping_template == "" ? " " : resolver.response_mapping_template
    }
  }

  // Pipeline resolvers
  pipeline_resolver_paths = distinct([
    for file in var.pipeline_resolvers_path == null ? [] : fileset(var.pipeline_resolvers_path, "*/*/*") :
    dirname(file)
  ])
  pipeline_resolver_info = {
    for resolver_path in local.pipeline_resolver_paths :
    resolver_path => {
      type                      = split(local.path_separator, resolver_path)[0]
      name                      = split(local.path_separator, resolver_path)[1]
      request_mapping_template  = file("${var.pipeline_resolvers_path}/${resolver_path}/request.vtl")
      response_mapping_template = file("${var.pipeline_resolvers_path}/${resolver_path}/response.vtl")
      functions                 = file("${var.pipeline_resolvers_path}/${resolver_path}/functions.txt")
    }
  }
  pipeline_resolvers = {
    for resolver in local.pipeline_resolver_info :
    "${resolver.type}/${resolver.name}" => {
      type                      = resolver.type
      name                      = resolver.name
      request_mapping_template  = resolver.request_mapping_template == "" ? " " : resolver.request_mapping_template
      response_mapping_template = resolver.response_mapping_template == "" ? " " : resolver.response_mapping_template
      functions = [for function in split("\n", resolver.functions) :
        trimspace(function)
        if length(trimspace(function)) > 0
      ]
    }
  }
}
