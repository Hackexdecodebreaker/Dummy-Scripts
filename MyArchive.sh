#!/usr/bin/env bash

if command -v figlet &> /dev/null; then
    figlet "Xcyberex"
elif command -v toilet &> /dev/null; then
    toilet "Xcyberex"
fi

if ! command -v zip &> /dev/null; then
    echo "Error: 'zip' utility is not installed." >&2
    exit 1
fi

read -p "Enter output zip filename (e.g., package.custom.zip): " OUTPUT_ZIP
read -p "Enter output format/extension label (e.g., custom, jar, apk): " FORMAT_LABEL
read -p "Enter space-separated list of files/directories to include: " INPUT_FILES

TEMP_DIR=$(mktemp -d)

MANIFEST_PATH="$TEMP_DIR/MANIFEST.MF"

cat <<EOF > "$MANIFEST_PATH"
Manifest-Version: 1.0
Created-By: Xcyberex Custom Packager
Package-Format: $FORMAT_LABEL
Build-Date: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOF

echo "Manifest created at $MANIFEST_PATH"

mkdir -p "$TEMP_DIR/contents"

for item in $INPUT_FILES; do
    if [[ -e "$item" ]]; then
        cp -r "$item" "$TEMP_DIR/contents/"
    else
        echo "Warning: '$item' does not exist, skipping."
    fi
done

echo "Creating ZIP archive..."
(cd "$TEMP_DIR/contents" && zip -r "$TEMP_DIR/temp_archive.zip" .)
(cd "$TEMP_DIR" && zip -u "$TEMP_DIR/temp_archive.zip" "MANIFEST.MF")

mv "$TEMP_DIR/temp_archive.zip" "./$OUTPUT_ZIP"
rm -rf "$TEMP_DIR"

if [[ -f "./$OUTPUT_ZIP" ]]; then
    echo "----------------------------------------"
    echo "Successfully created: $OUTPUT_ZIP"
    echo "Format specified: $FORMAT_LABEL"
    echo "----------------------------------------"
else
    echo "Error: Failed to create $OUTPUT_ZIP" >&2
    exit 1
fi