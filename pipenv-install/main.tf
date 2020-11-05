locals {
  // Append a trailing slash if there isn't already one
  is_windows            = dirname("/") == "\\"
  working_dir           = abspath(var.working_dir)
  pipfile               = "${local.working_dir}/Pipfile"
  pipfile_lock          = "${local.working_dir}/Pipfile.lock"
  pipfile_exists        = fileexists(local.pipfile)
  pipfile_lock_exists   = fileexists(local.pipfile_lock)
  pipfile_contents      = local.pipfile_exists ? file(local.pipfile) : ""
  pipfile_lock_contents = local.pipfile_lock_exists ? file(local.pipfile_lock) : ""
  venv_name             = ".venv"
  venv_path             = "${local.working_dir}/${local.venv_name}"
  dependency_hash_file  = "dependency_hash"
  dependency_hash_path  = "${local.working_dir}/${local.venv_name}/${local.dependency_hash_file}"
  new_dependency_hash   = base64sha256("${local.pipfile_contents}${local.pipfile_lock_contents}")
  dependency_path       = "${local.venv_path}/Lib/site-packages"
  dependency_archive    = "${local.venv_path}/dependencies.zip"
  source_archive        = "${local.venv_path}/source.zip"
  archive_temp_dir      = "${local.venv_path}/.temparchive"
  archive_internal_path = "python"
  package_archive       = abspath(var.archive_file == null ? "${dirname(local.working_dir)}/${basename(local.working_dir)}.zip" : var.archive_file)
}

resource "local_file" "dependency_hash" {
  depends_on = [
    module.assert_pipenv_exists.checked,
    module.assert_zip_exists.checked,
    module.assert_pipfile.checked,
    module.assert_piplock.checked,
    module.assert_archive_is_zip.checked,
  ]
  content  = local.new_dependency_hash
  filename = local.dependency_hash_path
}

data "local_file" "dependency_hash" {
  depends_on = [local_file.dependency_hash]
  filename   = local_file.dependency_hash.filename
}

resource "null_resource" "pipenv_install" {
  count = local.pipfile_exists ? 1 : 0
  depends_on = [
    module.assert_pipenv_exists.checked,
    module.assert_zip_exists.checked,
    module.assert_pipfile.checked,
    module.assert_piplock.checked,
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
      PIPENV_VENV_IN_PROJECT = true
      VENV_PATH              = local.is_windows ? replace(local.venv_path, "/", "\\") : local.venv_path
      DEPENDENCY_PATH        = local.is_windows ? replace(local.dependency_path, "/", "\\") : local.dependency_path
      DEPENDENCY_HASH_FILE   = local.dependency_hash_file
    }
  }
}

data "archive_file" "source" {
  count       = var.create_archive ? 1 : 0
  depends_on  = [null_resource.pipenv_install]
  type        = "zip"
  source_dir  = local.working_dir
  output_path = local.source_archive
  excludes = [
    local.venv_name,
    "pipfile",
    "Pipfile",
    "Pipfile.lock"
  ]
}

resource "null_resource" "merge_archives" {
  count = var.create_archive ? 1 : 0
  depends_on = [
    data.archive_file.source,
    null_resource.pipenv_install
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
      DEPENDENCIES_EXIST   = length(null_resource.pipenv_install) > 0 ? true : null
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
