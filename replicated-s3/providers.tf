provider "aws" {
  alias = "primary"
  /*
  region      = var.primary_region
  profile     = var.provider_profile
  access_key  = var.provider_profile != null ? null : var.provider_access_key_id
  secret_key  = var.provider_profile != null ? null : var.provider_access_key_secret
  max_retries = 10

  dynamic "assume_role" {
    for_each = var.provider_role_to_assume != null ? [1] : []
    content {
      role_arn = var.provider_role_to_assume
    }
  }
  */
}

provider "aws" {
  alias = "secondary"
  /*
  region      = var.secondary_region
  profile     = var.provider_profile
  access_key  = var.provider_profile != null ? null : var.provider_access_key_id
  secret_key  = var.provider_profile != null ? null : var.provider_access_key_secret
  max_retries = 10

  dynamic "assume_role" {
    for_each = var.provider_role_to_assume != null ? [1] : []
    content {
      role_arn = var.provider_role_to_assume
    }
  }
  */
}
