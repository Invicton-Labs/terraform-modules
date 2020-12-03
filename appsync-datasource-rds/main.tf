resource "random_id" "stack" {
  byte_length = 8
}

resource "aws_cloudformation_stack" "datasource" {
  name = "appsync-datasource-rds-${random_id.stack.hex}"

  parameters = {
    ApiId               = var.api_id
    Name                = var.name
    Description         = var.description
    ServiceRoleArn      = var.service_role_arn
    AwsRegion           = var.aws_region
    AwsSecretStoreArn   = var.aws_secret_store_arn
    DbClusterIdentifier = var.database_cluster_arn
    DatabaseName        = var.database_name
    Schema              = var.schema
  }

  template_body = <<STACK
{
  "Parameters" : {
    "ApiId" : {
      "Type" : "String"
    },
    "Name" : {
      "Type" : "String"
    },
    "Description" : {
      "Type" : "String"
    },
    "ServiceRoleArn" : {
      "Type" : "String"
    },
    "AwsRegion" : {
      "Type" : "String"
    },
    "AwsSecretStoreArn" : {
      "Type" : "String"
    },
    "DbClusterIdentifier" : {
      "Type" : "String"
    },
    "DatabaseName" : {
      "Type" : "String"
    },
    "Schema" : {
      "Type" : "String",
      "Default": ""
    }
  },
  "Resources" : {
    "DatasourceRDS": {
      "Type" : "AWS::AppSync::DataSource",
      "Properties" : {
          "ApiId" : { "Ref" : "ApiId" },
          "Description" : { "Ref" : "Description" },
          "Name" : { "Ref" : "Name" },
          "RelationalDatabaseConfig" : {
            "RdsHttpEndpointConfig" : {
              "AwsRegion" : { "Ref" : "AwsRegion" },
              "AwsSecretStoreArn" : { "Ref" : "AwsSecretStoreArn" },
              "DatabaseName" : { "Ref" : "DatabaseName" },
              "DbClusterIdentifier" : { "Ref" : "DbClusterIdentifier" },
              "Schema": { "Ref" : "Schema" }
            },
            "RelationalDatabaseSourceType" : "RDS_HTTP_ENDPOINT"
          },
          "ServiceRoleArn" : { "Ref" : "ServiceRoleArn" },
          "Type" : "RELATIONAL_DATABASE"
        }
    }
  },
  "Outputs" : {
    "Arn" : {
      "Value" : { "Fn::GetAtt" : [ "DatasourceRDS", "DataSourceArn" ] }
    },
    "Name" : {
      "Value" : { "Fn::GetAtt" : [ "DatasourceRDS", "Name" ] }
    }
  }
}
STACK
}
