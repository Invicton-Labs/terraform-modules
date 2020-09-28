locals {
  is_windows = dirname("/") == "\\"
}

data "external" "info" {
  program     = local.is_windows ? ["Powershell.exe", "${path.module}/info.ps1"] : ["bash", "${path.module}/info.sh"]
  working_dir = var.working_dir != null ? var.working_dir : path.root
}
