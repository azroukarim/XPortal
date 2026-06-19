#!/bin/sh

echo "=================================================================="
echo "   XPortal Plugin Online Installer"
echo "=================================================================="

# Check Python version
PY_FULL_VER=$(python3 -c 'import sys; print("%d.%d.%d" % sys.version_info[:3])' 2>/dev/null)

if [ -z "$PY_FULL_VER" ]; then
    echo "Error: Python 3 is required but not found on this system."
    exit 1
fi

echo "Detected Python version: $PY_FULL_VER"

# Direct download links provided
URL_314="https://github.com/azroukarim/XPortal/raw/refs/heads/main/enigma2-plugin-extensions-xportal_2.0_py3.14.5_all.ipk"
URL_313="https://github.com/azroukarim/XPortal/raw/refs/heads/main/enigma2-plugin-extensions-xportal_2.0_py3.13.12_all.ipk"

DOWNLOAD_URL=""

# Match python version to appropriate download link
case "$PY_FULL_VER" in
    3.14.*)
        DOWNLOAD_URL="$URL_314"
        ;;
    3.13.*)
        DOWNLOAD_URL="$URL_313"
        ;;
    3.12.*)
        # Using 3.13 package for 3.12 as a compatible match or fallback
        echo "Python 3.12 detected. Using Python 3.13 package."
        DOWNLOAD_URL="$URL_313"
        ;;
    *)
        # Default fallback to 3.13
        echo "Warning: Python version $PY_FULL_VER is not explicitly matched. Attempting to use Python 3.13 package."
        DOWNLOAD_URL="$URL_313"
        ;;
esac

# Check for download tools (wget or curl)
# Note: --no-check-certificate / -k is used because Enigma2 devices often lack updated SSL certificates
if command -v wget >/dev/null 2>&1; then
    DOWNLOAD_CMD="wget --no-check-certificate -qO /tmp/xportal.ipk"
elif command -v curl >/dev/null 2>&1; then
    DOWNLOAD_CMD="curl -k -Ls -o /tmp/xportal.ipk"
else
    echo "Error: Neither wget nor curl is installed on this system."
    exit 1
fi

echo "Downloading package..."
echo "Source: $DOWNLOAD_URL"

# Execute download
$DOWNLOAD_CMD "$DOWNLOAD_URL"

if [ $? -ne 0 ] || [ ! -f /tmp/xportal.ipk ] || [ ! -s /tmp/xportal.ipk ]; then
    echo "Error: Download failed. Please check your internet connection."
    rm -f /tmp/xportal.ipk
    exit 1
fi

echo "Installing..."
# Run opkg install
opkg install /tmp/xportal.ipk

if [ $? -eq 0 ]; then
    echo "=================================================================="
    echo "   Installation completed successfully!"
    echo "   Please restart Enigma2 to apply changes."
    echo "=================================================================="
else
    echo "=================================================================="
    echo "   Installation failed! Check the output above for errors."
    echo "=================================================================="
fi

# Clean up temporary installer file
rm -f /tmp/xportal.ipk
