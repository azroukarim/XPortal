#!/bin/sh

echo "=================================================================="
echo "   XPortal Plugin Installer"
echo "=================================================================="

# Detect Python version
PY_VER=$(python3 -c 'import sys; print("%d.%d.%d" % sys.version_info[:3])' 2>/dev/null)

if [ -z "$PY_VER" ]; then
    echo "Error: Python 3 not found on this system."
    exit 1
fi

echo "Detected Python version: $PY_VER"

# Select download URL based on Python version
case "$PY_VER" in
    3.14.*)
        DOWNLOAD_URL="https://github.com/azroukarim/XPortal/raw/refs/heads/main/XPortal-py3_14.tar.gz"
        ;;
    3.13.*)
        DOWNLOAD_URL="https://github.com/azroukarim/XPortal/raw/refs/heads/main/XPortal-py3_13.tar.gz"
        ;;
    3.9.*)
        DOWNLOAD_URL="https://github.com/azroukarim/XPortal/raw/refs/heads/main/XPortal-py3_9.tar.gz"
        ;;
    *)
        echo "Error: Python $PY_VER is not supported. Only 3.9.x, 3.13.x and 3.14.x are supported."
        exit 1
        ;;
esac

TAR_FILE="XPortal.tar.gz"
TMP_DIR="/tmp"
EXTRACTED_DIR="$TMP_DIR/XPortal"
DEST_DIR="/usr/lib/enigma2/python/Plugins/Extensions/XPortal"

# Check for download tools
if command -v wget >/dev/null 2>&1; then
    DOWNLOAD_CMD="wget --no-check-certificate -qO"
elif command -v curl >/dev/null 2>&1; then
    DOWNLOAD_CMD="curl -k -Ls -o"
else
    echo "Error: Neither wget nor curl is installed."
    exit 1
fi

echo "[1/5] Downloading..."
$DOWNLOAD_CMD "$TMP_DIR/$TAR_FILE" "$DOWNLOAD_URL"
if [ $? -ne 0 ] || [ ! -f "$TMP_DIR/$TAR_FILE" ] || [ ! -s "$TMP_DIR/$TAR_FILE" ]; then
    echo "Error: Download failed. Check your internet connection."
    rm -f "$TMP_DIR/$TAR_FILE"
    exit 1
fi

echo "[2/5] Extracting $TAR_FILE..."
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

echo "[3/5] Installing to $DEST_DIR..."
if [ -d "$DEST_DIR" ]; then
    echo "  Removing old version..."
    rm -rf "$DEST_DIR"
fi

mv "$EXTRACTED_DIR" "$DEST_DIR"
if [ $? -ne 0 ]; then
    echo "Error: Failed to move files to $DEST_DIR"
    exit 1
fi

echo "[4/5] Cleaning up..."
rm -f "$TMP_DIR/$TAR_FILE"

echo "[5/5] Restarting Enigma2..."
killall -9 enigma2 2>/dev/null

echo "=================================================================="
echo "   Installation completed successfully!"
echo "   Enigma2 is restarting..."
echo "=================================================================="
