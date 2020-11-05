#!/bin/bash
set -e

# Delete the temp archive dir
rm -rf "$ARCHIVE_TEMP_DIR"
archive_internal_dir="$ARCHIVE_TEMP_DIR/$ARCHIVE_INTERNAL_DIR"
# Create the temp archive internal dir
mkdir -p "$archive_internal_dir"
# Unzip the source files zip into the temp archive internal dir
unzip "$SOURCE_ARCHIVE" -d "$archive_internal_dir"
# If there are dependencies, find and copy them
if ! [ -z ${DEPENDENCIES_EXIST+x} ]; then
    # Find the site-packages directory within
    libpath="$VENV_PATH/lib"
    readarray -d '' libdirs < <(find "$libpath" -maxdepth 1 -type d ! -path "$libpath" -print0)
    numdir=${#libdirs[@]}
    if [ $numdir -ne 1 ]; then
        >&2 echo "Failed to detect site-packages path. Expected 1 directory in $libpath, found $numdir."
        exit 1
    fi
    dependency_dir="${libdirs[0]}/site-packages"
    # Copy all dependency directories to the temp archive directory
    find "$dependency_dir" -maxdepth 1 -type d ! -path "$dependency_dir" -exec cp -R {} "$archive_internal_dir/" \;
fi
# Remove any existing archive
rm -rf "$PACKAGE_ARCHIVE"
