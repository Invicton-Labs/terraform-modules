// Check if Pipenv is installed
module "pip_exists" {
  source  = "../command-exists"
  command = "pip3"
}

// Make sure Pip is installed
module "assert_pip_exists" {
  source        = "../assert"
  condition     = module.pip_exists.exists
  error_message = "'pip3' command not found. Pip must be installed to use the 'pip-install' module."
}

// Check if zip is installed
module "unzip_exists" {
  source  = "../command-exists"
  command = "unzip"
}

// Make sure Unzip is installed
module "assert_unzip_exists" {
  source        = "../assert"
  condition     = module.unzip_exists.exists || local.is_windows
  error_message = "'unzip' command not found. Unzip must be installed to use the 'pipenv-install' module on Unix-based operating systems."
}

// Make sure there's a requirements.txt file to install from
module "assert_requirements_file" {
  source        = "../assert"
  condition     = local.requirements_exists || var.suppress_non_existance_error
  error_message = "No requirements.txt found in project directory (${local.working_dir})."
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
