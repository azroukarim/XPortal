#!/bin/sh

# ==========================================================
# Colors
# ==========================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ==========================================================
# XPortal Plugin Installer Script for Enigma2
# ==========================================================


echo -e "${BLUE}==========================================================${NC}"
echo -e "${BOLD}${YELLOW}          XPortal Plugin Installer Started             ${NC}"
echo -e "${BLUE}==========================================================${NC}"
echo ""

# 1. Remove old version completely
echo -e "${CYAN}[1/5]${NC} ${BOLD}Removing old version...${NC}"
opkg remove enigma2-plugin-extensions-xportal --force-depends > /dev/null 2>&1
rm -rf /usr/lib/enigma2/python/Plugins/Extensions/XPortal > /dev/null 2>&1
echo -e "      ${GREEN}✓ Old version removed.${NC}\n"

# 2. Download the new version
echo -e "${CYAN}[2/5]${NC} ${BOLD}Downloading latest IPK from GitHub...${NC}"
URL="https://github.com/azroukarim/XPortal/releases/download/v1.2/enigma2-plugin-extensions-xportal_v1.2_all.ipk"
IPK_TMP="/tmp/xportal_install.ipk"

wget -q --show-progress -O $IPK_TMP $URL

if [ ! -f $IPK_TMP ]; then
    echo -e "      ${RED}✗ Error: Failed to download the file. Please check your internet connection or URL.${NC}"
    exit 1
fi
echo -e "      ${GREEN}✓ Download complete.${NC}\n"

# 3. Install required dependencies
echo -e "${CYAN}[3/5]${NC} ${BOLD}Installing required dependencies (requests, twisted, serviceapp, players)...${NC}"
opkg update > /dev/null 2>&1
opkg install python3-requests python3-twisted enigma2-plugin-systemplugins-serviceapp exteplayer3 gstplayer > /dev/null 2>&1
echo -e "      ${GREEN}✓ Dependencies installed.${NC}\n"

# 4. Install the plugin
echo -e "${CYAN}[4/5]${NC} ${BOLD}Installing XPortal Plugin...${NC}"
opkg install --force-reinstall --force-overwrite $IPK_TMP
echo -e "      ${GREEN}✓ Plugin installed successfully.${NC}\n"

# 5. Clean up and restart GUI
echo -e "${CYAN}[5/5]${NC} ${BOLD}Cleaning up...${NC}"
rm -f $IPK_TMP
echo -e "      ${GREEN}✓ Clean up done.${NC}\n"

echo -e "${BLUE}==========================================================${NC}"
echo -e "${BOLD}${GREEN}       XPortal Plugin Installed Successfully!          ${NC}"
echo -e "${BLUE}==========================================================${NC}"
echo ""
echo -e "${MAGENTA} ******************** MESSAGE ********************      ${NC}"
echo -e "${BOLD} This plugin is free and will remain free forever,      ${NC}"
echo -e "${BOLD} as long as not a single euro was spent on it!          ${NC}"
echo -e "                                                        "
echo -e "${CYAN} Best regards and thanks to everyone.                   ${NC}"
echo -e "${CYAN} - Karim                                                ${NC}"
echo -e "${MAGENTA} *************************************************      ${NC}"
echo ""
echo -e "${YELLOW}       Enigma2 GUI will restart in 3 seconds...         ${NC}"
echo -e "${BLUE}==========================================================${NC}"
sleep 3
killall -9 enigma2
