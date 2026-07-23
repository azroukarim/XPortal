#!/bin/sh

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo ""
echo -e "${CYAN}==================================================================${NC}"
echo -e "${YELLOW}                 XPortal Plugin Installer                       ${NC}"
echo -e "${CYAN}==================================================================${NC}"
echo ""

# 1. Install required dependencies
echo -e "${BLUE}[1/6] Installing dependencies...${NC}"
opkg update >/dev/null 2>&1
for pkg in wget python3-requests python3-twisted enigma2-plugin-systemplugins-serviceapp exteplayer3; do
    echo -e "  ${YELLOW}➔ Checking and installing $pkg...${NC}"
    opkg install $pkg >/dev/null 2>&1
done

# Detect Python version
PY_VER=$(python3 -c 'import sys; print("%d.%d.%d" % sys.version_info[:3])' 2>/dev/null)

if [ -z "$PY_VER" ]; then
    echo -e "${RED}✘ Error: Python 3 not found on this system.${NC}"
    exit 1
fi

echo -e "  ${GREEN}✔ Detected Python version: $PY_VER${NC}"
echo ""

# Select download URL based on Python version
case "$PY_VER" in
    3.14.*)
        DOWNLOAD_URL="https://vqyuhxdqegasanwnjrzo.supabase.co/storage/v1/object/public/downloads/XPortal-py3_14.tar.gz"
        ;;
    3.13.*)
        DOWNLOAD_URL="https://github.com/azroukarim/XPortal/raw/refs/heads/main/XPortal-py3_13.tar.gz"
        ;;
    3.12.*)
        DOWNLOAD_URL="https://github.com/azroukarim/XPortal/raw/refs/heads/main/XPortal-py3_12.tar.gz"
        ;;
    3.9.*)
        DOWNLOAD_URL="https://github.com/azroukarim/XPortal/raw/refs/heads/main/XPortal-py3_9.tar.gz"
        ;;
    *)
        echo -e "${RED}✘ Error: Python $PY_VER is not supported. Only 3.9.x, 3.12.x, 3.13.x and 3.14.x are supported.${NC}"
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
    echo -e "${RED}✘ Error: Neither wget nor curl is installed.${NC}"
    exit 1
fi

echo -e "${BLUE}[2/6] Downloading XPortal...${NC}"
$DOWNLOAD_CMD "$TMP_DIR/$TAR_FILE" "$DOWNLOAD_URL"
if [ $? -ne 0 ] || [ ! -f "$TMP_DIR/$TAR_FILE" ] || [ ! -s "$TMP_DIR/$TAR_FILE" ]; then
    echo -e "${RED}✘ Error: Download failed. Please check your internet connection.${NC}"
    rm -f "$TMP_DIR/$TAR_FILE"
    exit 1
fi
echo -e "  ${GREEN}✔ Download completed successfully.${NC}"
echo ""

echo -e "${BLUE}[3/6] Extracting files...${NC}"
cd "$TMP_DIR"
tar -xzf "$TAR_FILE"
if [ $? -ne 0 ]; then
    echo -e "${RED}✘ Error: Failed to extract $TAR_FILE${NC}"
    exit 1
fi

if [ ! -d "$EXTRACTED_DIR" ]; then
    echo -e "${RED}✘ Error: Extracted folder XPortal not found${NC}"
    exit 1
fi
echo -e "  ${GREEN}✔ Extraction successful.${NC}"
echo ""

echo -e "${BLUE}[4/6] Installing to Enigma2...${NC}"
if [ -d "$DEST_DIR" ]; then
    echo -e "  ${YELLOW}➔ Removing old version...${NC}"
    rm -rf "$DEST_DIR"
fi

mv "$EXTRACTED_DIR" "$DEST_DIR"
if [ $? -ne 0 ]; then
    echo -e "${RED}✘ Error: Failed to move files to destination.${NC}"
    exit 1
fi
echo -e "  ${GREEN}✔ Installation successful.${NC}"
echo ""

echo -e "${BLUE}[5/6] Cleaning up temporary files...${NC}"
rm -f "$TMP_DIR/$TAR_FILE"
echo -e "  ${GREEN}✔ Cleanup complete.${NC}"
echo ""

echo -e "${BLUE}[6/6] Restarting Enigma2...${NC}"
echo ""
echo -e "${CYAN}==================================================================${NC}"
echo -e "${GREEN}             Installation completed successfully!                 ${NC}"
echo -e "${CYAN}==================================================================${NC}"
echo ""
echo -e "${YELLOW}  A huge THANK YOU to everyone who supported this plugin,${NC}"
echo -e "${YELLOW}  whether from near or far. Special thanks to all the users${NC}"
echo -e "${YELLOW}  who tested the plugin on their receivers and helped improve it.${NC}"
echo -e "${YELLOW}  Your support means everything! Enjoy XPortal! ❤️${NC}"
echo ""
echo -e "${CYAN}==================================================================${NC}"
echo -e "  ${BLUE}➔ Enigma2 is restarting now...${NC}"

# Restart Enigma2
killall -9 enigma2 2>/dev/null

exit 0
