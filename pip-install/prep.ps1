$ErrorActionPreference = "Stop"

# Delete the temp archive dir
If (Test-Path "$Env:ARCHIVE_TEMP_DIR") {
    Remove-Item -Recurse "$Env:ARCHIVE_TEMP_DIR" -Force
}

$archive_internal_dir = "$Env:ARCHIVE_TEMP_DIR\$Env:ARCHIVE_INTERNAL_DIR"

# Create the temp archive internal dir
New-Item -ItemType Directory -Path "$archive_internal_dir"

# If there are dependencies, find and copy them
if (Test-Path env:DEPENDENCIES_EXIST) { 
    # Copy all dependency directories to the temp archive directory
    Get-ChildItem "$Env:DEPENDENCY_PATH" | Where-Object { $_.PSIsContainer } | Copy-Item -LiteralPath { $_.FullName } -Recurse -Destination "$archive_internal_dir"
}

# Unzip the source files zip into the temp archive internal dir (overwriting any dependency files)
Expand-Archive -LiteralPath "$Env:SOURCE_ARCHIVE" "$archive_internal_dir" -Force

# Remove any existing archive
If (Test-Path "$Env:PACKAGE_ARCHIVE") {
    Remove-Item "$Env:PACKAGE_ARCHIVE" -Force
}
