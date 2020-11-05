$ErrorActionPreference = "Stop"
If (Test-Path "$Env:ARCHIVE_TEMP_DIR") {
    Remove-Item -Recurse "$Env:ARCHIVE_TEMP_DIR" -Force
}
$archive_internal_dir = "$Env:ARCHIVE_TEMP_DIR\$Env:ARCHIVE_INTERNAL_DIR"
New-Item -ItemType Directory -Path "$archive_internal_dir"
Expand-Archive -LiteralPath "$Env:SOURCE_ARCHIVE" "$archive_internal_dir"
if (Test-Path 'env:DEPENDENCIES_EXIST') { 
    Get-ChildItem "$Env:DEPENDENCY_PATH" | Where-Object { $_.PSIsContainer } | Copy-Item -LiteralPath { $_.FullName } -Destination "$archive_internal_dir"
}
