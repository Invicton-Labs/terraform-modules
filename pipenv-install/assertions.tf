// Check if Pipenv is installed
module "pipenv_exists" {
  source  = "../command-exists"
  command = "pipenv"
}

// Make sure Pipenv is installed
module "assert_pipenv_exists" {
  source        = "../assert"
  condition     = module.pipenv_exists.exists
  error_message = "'pipenv' command not found. Pipenv must be installed to use the 'pipenv-install' module."
}

// Check if zip is installed
module "unzip_exists" {
  source  = "../command-exists"
  command = "unzip"
}

// Make sure Pipenv is installed
module "assert_unzip_exists" {
  source        = "../assert"
  condition     = module.unzip_exists.exists || local.is_windows
  error_message = "'unzip' command not found. Unzip must be installed to use the 'pipenv-install' module on Unix-based operating systems."
}

// Make sure there's a Pipfile to install from
module "assert_pipfile" {
  source        = "../assert"
  condition     = local.pipfile_exists || var.suppress_non_existance_error
  error_message = "No Pipfile found in project directory (${local.working_dir})."
}

// Make sure there's a Pipfile.lock to install from
module "assert_piplock" {
  source = "../assert"
  // The piplock must exist, or it must be OK to not have one, or it's OK to not have pipfiles and there isn't a regular Pipfile either
  condition     = local.pipfile_lock_exists || ! var.require_piplock || (var.suppress_non_existance_error && ! local.pipfile_exists)
  error_message = "No Pipfile found in project directory (${local.working_dir})."
}

locals {
  archive_file_split_basename = split(".", basename(local.package_archive))
}

// Make sure the archive file ends in ".zip"
module "assert_archive_is_zip" {
  source        = "../assert"
  condition     = length(local.archive_file_split_basename) > 1 && lower(local.archive_file_split_basename[length(local.archive_file_split_basename) - 1]) == "zip"
  error_message = "The value of the `archive_file` variable, if provided, must end in `.zip`."
}
