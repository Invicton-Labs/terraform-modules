locals {
  base_dir = var.working_dir != null ? var.working_dir : path.root
  // This file always exists for all initialized installations
  init_path          = "${local.base_dir}/.terraform/terraform.tfstate"
  init_found         = fileexists(local.init_path)
  init_contents      = local.init_found ? jsondecode(file(local.init_path)) : null
  backend            = local.init_found ? lookup(local.init_contents, "backend", null) : null
  backend_configured = local.backend != null
}
