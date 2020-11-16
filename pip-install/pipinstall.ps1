$ErrorActionPreference = "Stop"
If (Test-Path "$Env:VENV_PATH") {
    Get-ChildItem "$Env:VENV_PATH" -Exclude "$Env:DEPENDENCY_HASH_FILE" | Remove-Item -Recurse
}
py -m pip install --requirement "$Env:REQUIREMENTS_FILE" --platform "$Env:PLATFORM" --target "$Env:TARGET_PATH" --python-version "$Env:PYTHON_VERSION" --no-deps --upgrade
# If the install failed for any reason, exit
If (-NOT  ($LASTEXITCODE -eq 0)) {
    Exit $LASTEXITCODE
} 
