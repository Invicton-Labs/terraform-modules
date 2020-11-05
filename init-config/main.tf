locals {
  base_dir = var.working_dir != null ? var.working_dir : path.root
  // This file always exists for all initialized installations
  init_path          = "${local.base_dir}/.terraform/terraform.tfstate"
  workspace_path     = "${local.base_dir}/.terraform/environment"
  init_found         = fileexists(local.init_path)
  init_contents      = local.init_found ? jsondecode(file(local.init_path)) : null
  backend            = local.init_found ? lookup(local.init_contents, "backend", null) : null
  backend_configured = local.backend != null
  workspace          = fileexists(local.workspace_path) ? file(local.workspace_path) : null
}

// Fetch the state, if desired
data "terraform_remote_state" "state" {
  count     = local.backend_configured && var.fetch_state ? 1 : 0
  backend   = local.backend.type
  config    = local.backend.config
  workspace = local.workspace
}
