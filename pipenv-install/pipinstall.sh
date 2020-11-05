#!/bin/bash
set -e

# Delete all files in the venv directory except the build-hash file
if [ -d "$VENV_PATH" ]; then
    find "$VENV_PATH" -maxdepth 1 ! -name 'build-hash' ! -path "$VENV_PATH"  -exec rm -rf {} +
fi
# Run pipenv install
pipenv install
