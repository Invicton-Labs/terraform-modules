#!/bin/bash
set -e

# Delete the temp archive dir
rm -rf "$ARCHIVE_TEMP_DIR"

archive_internal_dir="$ARCHIVE_TEMP_DIR/$ARCHIVE_INTERNAL_DIR"

# Create the temp archive internal dir
mkdir -p "$archive_internal_dir"

# If there are dependencies, find and copy them
if ! [ -z ${DEPENDENCIES_EXIST+x} ]; then
    # Copy all dependency directories to the temp archive directory
    find "$DEPENDENCY_PATH" -maxdepth 1 -type d ! -path "$DEPENDENCY_PATH" -exec cp -R {} "$archive_internal_dir/" \;
fi

# Unzip the source files zip into the temp archive internal dir (overwriting any dependency files)
unzip -o "$SOURCE_ARCHIVE" -d "$archive_internal_dir"

# Remove any existing archive
rm -rf "$PACKAGE_ARCHIVE"
