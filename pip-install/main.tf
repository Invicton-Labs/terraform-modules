locals {
  // Append a trailing slash if there isn't already one
  is_windows            = dirname("/") == "\\"
  working_dir           = abspath(var.working_dir)
  requirements_file     = "${local.working_dir}/${var.requirements_file}"
  requirements_exists   = fileexists(local.requirements_file)
  requirements_contents = local.requirements_exists ? file(local.requirements_file) : ""
  venv_name             = ".venv"
  venv_path             = "${local.working_dir}/${local.venv_name}"
  archive_internal_path = "python"
  dependency_path       = "${local.venv_path}/${local.archive_internal_path}"
  dependency_hash_file  = "dependency_hash"
  dependency_hash_path  = "${local.venv_path}/${local.dependency_hash_file}"
  new_dependency_hash   = base64sha256(local.requirements_contents)
  source_archive        = "${local.venv_path}/source.zip"
  archive_temp_dir      = "${local.venv_path}/.temparchive"
  package_archive       = abspath(var.archive_file == null ? "${dirname(local.working_dir)}/${basename(local.working_dir)}.zip" : var.archive_file)
}

// Create the directory to be bundled in the end, so no errors are thrown for it not existing
data "external" "create_empty_archive_source" {
  count   = var.create_archive ? 1 : 0
  program = local.is_windows ? ["Powershell.exe", "${path.module}/mkdir.ps1", replace(local.archive_temp_dir, "/", "\\")] : ["bash", "${path.module}/mkdir.sh", local.archive_temp_dir]
}

resource "local_file" "dependency_hash" {
  depends_on = [
    module.assert_pip_exists.checked,
    module.assert_unzip_exists.checked,
    module.assert_requirements_file.checked,
    module.assert_archive_is_zip.checked,
  ]
  content  = local.new_dependency_hash
  filename = local.dependency_hash_path
}

data "local_file" "dependency_hash" {
  depends_on = [local_file.dependency_hash]
  filename   = local_file.dependency_hash.filename
}

resource "null_resource" "pip_install" {
  count = local.requirements_exists ? 1 : 0
  depends_on = [
    module.assert_pip_exists.checked,
    module.assert_unzip_exists.checked,
    module.assert_requirements_file.checked,
    module.assert_archive_is_zip.checked,
  ]
  triggers = {
    dependency_hash = data.local_file.dependency_hash.content
  }
  provisioner "local-exec" {
    command     = local.is_windows ? "${abspath(path.module)}/pipinstall.ps1" : "${abspath(path.module)}/pipinstall.sh"
    interpreter = [local.is_windows ? "Powershell.exe" : "bash"]
    working_dir = local.working_dir
    environment = {
      PYTHON_VERSION       = var.python_version
      PLATFORM             = var.platform
      VENV_PATH            = local.is_windows ? replace(local.venv_path, "/", "\\") : local.venv_path
      DEPENDENCY_HASH_FILE = local.is_windows ? replace(local.dependency_hash_file, "/", "\\") : local.dependency_hash_file
      REQUIREMENTS_FILE    = local.is_windows ? replace(local.requirements_file, "/", "\\") : local.requirements_file
      TARGET_PATH          = local.is_windows ? replace(local.dependency_path, "/", "\\") : local.dependency_path
    }
  }
}

data "archive_file" "source" {
  count = var.create_archive ? 1 : 0
  depends_on = [
    data.external.create_empty_archive_source,
    null_resource.pip_install
  ]
  type        = "zip"
  source_dir  = local.working_dir
  output_path = local.source_archive
  excludes = [
    local.venv_name,
    "pipfile",
    "Pipfile",
    "Pipfile.lock",
    var.requirements_file
  ]
}

resource "null_resource" "merge_archives" {
  count = var.create_archive ? 1 : 0
  depends_on = [
    data.archive_file.source,
    null_resource.pip_install
  ]
  // Trigger a rebuild if either the dependencies or the source changed
  triggers = {
    dependencies = data.local_file.dependency_hash.content
    source       = data.archive_file.source[0].output_base64sha256
  }
  provisioner "local-exec" {
    command     = local.is_windows ? "${abspath(path.module)}/prep.ps1" : "${abspath(path.module)}/prep.sh"
    interpreter = [local.is_windows ? "Powershell.exe" : "bash"]
    working_dir = local.working_dir
    environment = {
      DEPENDENCY_PATH      = local.is_windows ? replace(local.dependency_path, "/", "\\") : local.dependency_path
      SOURCE_ARCHIVE       = local.is_windows ? replace(local.source_archive, "/", "\\") : local.source_archive
      ARCHIVE_TEMP_DIR     = local.is_windows ? replace(local.archive_temp_dir, "/", "\\") : local.archive_temp_dir
      ARCHIVE_INTERNAL_DIR = local.is_windows ? replace(local.archive_internal_path, "/", "\\") : local.archive_internal_path
      PACKAGE_ARCHIVE      = local.is_windows ? replace(local.package_archive, "/", "\\") : local.package_archive
      VENV_PATH            = local.is_windows ? replace(local.venv_path, "/", "\\") : local.venv_path
      DEPENDENCIES_EXIST   = length(null_resource.pip_install) > 0 ? true : null
    }
  }
}

data "archive_file" "archive" {
  count       = var.create_archive ? 1 : 0
  depends_on  = [null_resource.merge_archives]
  type        = "zip"
  source_dir  = local.archive_temp_dir
  output_path = local.package_archive
}
