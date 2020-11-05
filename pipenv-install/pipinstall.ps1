$ErrorActionPreference = "Stop"
If (Test-Path "$Env:VENV_PATH") {
    Get-ChildItem "$Env:VENV_PATH" -Exclude "build-hash" | Remove-Item -Recurse
}
pipenv install
# If the install failed for any reason, exit
If (-NOT  ($LASTEXITCODE -eq 0)) {
    Exit $LASTEXITCODE
} 
