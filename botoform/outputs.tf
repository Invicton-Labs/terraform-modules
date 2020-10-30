output "results" {
  description = "The results of the script executions."
  value = {
    for key in keys(data.aws_lambda_invocation.botoform) :
    key => jsondecode(data.aws_lambda_invocation.botoform[key].result)
  }
}
