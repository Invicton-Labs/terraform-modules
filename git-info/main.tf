locals {
  is_windows = dirname("/") == "\\"
  is_git     = tobool(data.external.info.result.is_git)
}

data "external" "info" {
  program     = local.is_windows ? ["Powershell.exe", "${abspath(path.module)}/run.ps1"] : ["bash", "${abspath(path.module)}/run.sh"]
  working_dir = var.working_dir != null ? var.working_dir : path.root
}
