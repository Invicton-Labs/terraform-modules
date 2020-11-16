#!/bin/bash
set -e

# Delete all files in the venv directory except the build-hash file
if [ -d "$VENV_PATH" ]; then
    find "$VENV_PATH" -maxdepth 1 ! -name "$DEPENDENCY_HASH_FILE" ! -path "$VENV_PATH"  -exec rm -rf {} +
fi

# Run pip install
python3 -m pip install --requirement "$REQUIREMENTS_FILE" --platform "$PLATFORM" --target "$TARGET_PATH" --python-version "$PYTHON_VERSION" --no-deps --upgrade
