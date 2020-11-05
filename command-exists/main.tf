locals {
  is_windows = dirname("/") == "\\"
  exists     = tobool(data.external.check.result.exists)
}

data "external" "check" {
  program = local.is_windows ? ["Powershell.exe", "${abspath(path.module)}/run.ps1", var.command] : ["bash", "${abspath(path.module)}/run.sh", var.command]
}
