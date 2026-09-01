@'
#!/bin/sh

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}==================================================================${NC}"
echo -e "${YELLOW}                 XPortal Plugin Installer                       ${NC}"
echo -e "${CYAN}==================================================================${NC}"
echo ""

BASE_URL="https://github.com/azroukarim/XPortal/raw/refs/heads/main"

# 1. Detect Python binary
PY_BIN=""
if command -v python3 >/dev/null 2>&1; then
    PY_BIN="python3"
elif command -v python >/dev/null 2>&1; then
    PY_BIN="python"
else
    echo -e "${RED}✘ Error: Python not found on this system.${NC}"
    exit 1
fi

# Detect Python version safely (Compatible with all Busybox versions)
PY_VER=$($PY_BIN -V 2>&1 | sed 's/Python //' | cut -d. -f1,2)
PY_BITS=$($PY_BIN -c "import struct; print(struct.calcsize('P')*8)" 2>/dev/null)
[ -z "$PY_BITS" ] && PY_BITS="32"

# 2. Detect Architecture
MACHINE=$(uname -m)
case "$MACHINE" in
    aarch64|arm64)
        if [ "$PY_BITS" = "64" ]; then ARCH="aarch64"; else ARCH="arm"; fi ;;
    arm*)   ARCH="arm" ;;
    mips*)  ARCH="mips" ;;
    *)
        echo -e "${RED}✘ Error: unsupported architecture '$MACHINE'.${NC}"
        exit 1 ;;
esac

echo -e "  ${GREEN}✔ Detected: Python $PY_VER ($PY_BITS-bit)  |  $MACHINE → $ARCH${NC}"
echo ""

# 3. Check Supported Builds
case "$ARCH" in
    arm)     SUPPORTED="2.7 3.9 3.12 3.13 3.14" ;;
    aarch64) SUPPORTED="3.14"                   ;;
    mips)    SUPPORTED="2.7 3.9 3.12 3.13 3.14" ;;
esac

FOUND=0
for v in $SUPPORTED; do
    if [ "$v" = "$PY_VER" ]; then
        FOUND=1
        break
    fi
done

if [ "$FOUND" != "1" ]; then
    echo -e "${RED}✘ Error: no build for $ARCH with Python $PY_VER.${NC}"
    echo -e "${YELLOW}  Available for $ARCH: $SUPPORTED${NC}"
    exit 1
fi

# 4. Install Dependencies
echo -e "${BLUE}[1/6] Installing dependencies...${NC}"
opkg update >/dev/null 2>&1

if [ "$PY_VER" = "2.7" ]; then
    PACKAGES="wget python-requests python-twisted enigma2-plugin-systemplugins-serviceapp exteplayer3"
else
    PACKAGES="wget python3-requests python3-twisted enigma2-plugin-systemplugins-serviceapp exteplayer3"
fi

for pkg in $PACKAGES; do
    echo -e "  ${YELLOW}→ Checking and installing $pkg...${NC}"
    opkg install $pkg >/dev/null 2>&1
done

# 5. Prepare Download URLs
PY_TAG=$(echo "$PY_VER" | tr '.' '_')
FILE_NAME="XPortal-${ARCH}-py${PY_TAG}.tar.gz"
DOWNLOAD_URL="$BASE_URL/$FILE_NAME"

TAR_FILE="XPortal.tar.gz"
TMP_DIR="/tmp"
EXTRACTED_DIR="$TMP_DIR/XPortal"
DEST_DIR="/usr/lib/enigma2/python/Plugins/Extensions/XPortal"

# 6. Check Download Tool
if command -v wget >/dev/null 2>&1; then
    DOWNLOAD_CMD="wget --no-check-certificate -qO"
elif command -v curl >/dev/null 2>&1; then
    DOWNLOAD_CMD="curl -k -Ls -o"
else
    echo -e "${RED}✘ Error: Neither wget nor curl is installed.${NC}"
    exit 1
fi

echo -e "${BLUE}[2/6] Downloading $FILE_NAME ...${NC}"
$DOWNLOAD_CMD "$TMP_DIR/$TAR_FILE" "$DOWNLOAD_URL"
if [ $? -ne 0 ] || [ ! -f "$TMP_DIR/$TAR_FILE" ] || [ ! -s "$TMP_DIR/$TAR_FILE" ]; then
    echo -e "${RED}✘ Error: Download failed. Please check your internet connection.${NC}"
    echo -e "${YELLOW}  URL: $DOWNLOAD_URL${NC}"
    rm -f "$TMP_DIR/$TAR_FILE"
    exit 1
fi
echo -e "  ${GREEN}✔ Download completed successfully.${NC}"
echo ""

echo -e "${BLUE}[3/6] Extracting files...${NC}"
rm -rf "$EXTRACTED_DIR"
cd "$TMP_DIR"
tar -xzf "$TAR_FILE"
if [ $? -ne 0 ] || [ ! -d "$EXTRACTED_DIR" ]; then
    echo -e "${RED}✘ Error: Failed to extract $TAR_FILE${NC}"
    rm -f "$TMP_DIR/$TAR_FILE"
    exit 1
fi
echo -e "  ${GREEN}✔ Extraction successful.${NC}"
echo ""

echo -e "${BLUE}[4/6] Installing to Enigma2...${NC}"
if [ -d "$DEST_DIR" ]; then
    echo -e "  ${YELLOW}→ Removing old version...${NC}"
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
echo -e "${YELLOW}  A huge THANK YOU to everyone who supported this plugin!${NC}"
echo -e "${YELLOW}  Enjoy XPortal!${NC}"
echo ""
echo -e "${CYAN}==================================================================${NC}"
echo -e "  ${BLUE}→ Enigma2 is restarting now...${NC}"

killall -9 enigma2 2>/dev/null

exit 0
'@ | Set-Content -Path "installer.sh" -Encoding UTF8

git add installer.sh
git commit -m "Fix python version detection for busybox sh"
git push origin main
