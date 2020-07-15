provider "aws" {
  alias       = "primary"
  region      = var.primary_region
  profile     = var.provider_profile
  max_retries = 10

  dynamic "assume_role" {
    for_each = var.provider_role_to_assume != null ? [1] : []
    content {
      role_arn = var.provider_role_to_assume
    }
  }
}

provider "aws" {
  alias       = "secondary"
  region      = var.secondary_region
  profile     = var.provider_profile
  max_retries = 10

  dynamic "assume_role" {
    for_each = var.provider_role_to_assume != null ? [1] : []
    content {
      role_arn = var.provider_role_to_assume
    }
  }
}
