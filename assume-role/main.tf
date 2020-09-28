locals {
  is_windows = dirname("/") == "\\"
}

data "external" "assumed-role-creds" {
  program = local.is_windows ? ["Powershell.exe", "${path.module}/assume-role.ps1"] : ["bash", "${path.module}/assume-role.sh"]
  query = {
    iam_role = var.role_arn,
    session  = var.session_name
    profile  = var.profile
  }
}
