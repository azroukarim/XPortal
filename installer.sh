#!/bin/sh

# ==========================================================
# Starplex Plugin Installer Script for Enigma2
# ==========================================================

echo "=========================================================="
echo "          Starplex Plugin Installer Started             "
echo "=========================================================="

# 1. Remove old version completely
echo "[1/5] Removing old version..."
opkg remove enigma2-plugin-extensions-starplex --force-depends > /dev/null 2>&1
rm -rf /usr/lib/enigma2/python/Plugins/Extensions/Starplex > /dev/null 2>&1
echo "Old version removed."

# 2. Download the new version
echo "[2/5] Downloading latest IPK from GitHub..."
URL="https://github.com/azroukarim/starplex/raw/refs/heads/main/enigma2-plugin-extensions-starplex_v1.0_all.ipk"
IPK_TMP="/tmp/starplex_install.ipk"

wget -q --show-progress -O $IPK_TMP $URL

if [ ! -f $IPK_TMP ]; then
    echo "[-] Error: Failed to download the file. Please check your internet connection or URL."
    exit 1
fi

# 3. Install required dependencies
echo "[3/5] Installing required dependencies (requests, twisted, serviceapp, players)..."
opkg update > /dev/null 2>&1
opkg install python3-requests python3-twisted enigma2-plugin-systemplugins-serviceapp exteplayer3 gstplayer

# 4. Install the plugin
echo "[4/5] Installing Starplex Plugin..."
opkg install --force-reinstall --force-overwrite $IPK_TMP

# 5. Clean up and restart GUI
echo "[5/5] Cleaning up..."
rm -f $IPK_TMP

echo "=========================================================="
echo "       Starplex Plugin Installed Successfully!          "
echo "                                                        "
echo " ******************** MESSAGE ********************      "
echo " This plugin is free and will remain free forever,      "
echo " as long as not a single euro was spent on it!          "
echo "                                                        "
echo " Best regards and thanks to everyone.                   "
echo " - Karim                                                "
echo " *************************************************      "
echo "                                                        "
echo "       Enigma2 GUI will restart in 3 seconds...         "
echo "=========================================================="
sleep 3
killall -9 enigma2
