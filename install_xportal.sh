#!/bin/sh

echo "=================================================================="
echo "   XPortal Plugin Installer"
echo "=================================================================="

TAR_FILE="XPortal_py3_13_12.tar.gz"
TMP_DIR="/tmp"
EXTRACTED_DIR="$TMP_DIR/XPortal"
DEST_DIR="/usr/lib/enigma2/python/Plugins/Extensions/XPortal"

# Check if file exists in /tmp
if [ ! -f "$TMP_DIR/$TAR_FILE" ]; then
    echo "Error: $TAR_FILE not found in $TMP_DIR"
    echo "Please upload the file to $TMP_DIR first."
    exit 1
fi

echo "[1/4] Extracting $TAR_FILE..."
cd "$TMP_DIR"
tar -xzf "$TAR_FILE"
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract $TAR_FILE"
    exit 1
fi

if [ ! -d "$EXTRACTED_DIR" ]; then
    echo "Error: Extracted folder XPortal not found"
    exit 1
fi

echo "[2/4] Installing to $DEST_DIR..."
# Remove old version if exists
if [ -d "$DEST_DIR" ]; then
    echo "  Removing old version..."
    rm -rf "$DEST_DIR"
fi

# Move new version
mv "$EXTRACTED_DIR" "$DEST_DIR"
if [ $? -ne 0 ]; then
    echo "Error: Failed to move files to $DEST_DIR"
    exit 1
fi

echo "[3/4] Cleaning up..."
rm -f "$TMP_DIR/$TAR_FILE"

echo "[4/4] Restarting Enigma2..."
killall -9 enigma2 2>/dev/null

echo "=================================================================="
echo "   Installation completed successfully!"
echo "   Enigma2 is restarting..."
echo "=================================================================="
