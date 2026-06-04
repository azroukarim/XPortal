#!/bin/sh

# ==========================================================
# Starplex Plugin Installer Script for Enigma2
# ==========================================================

echo "=========================================================="
echo "          Starplex Plugin Installer Started             "
echo "=========================================================="

# 1. Remove old version completely
echo "[1/4] Removing old version..."
opkg remove enigma2-plugin-extensions-starplex --force-depends > /dev/null 2>&1
rm -rf /usr/lib/enigma2/python/Plugins/Extensions/Starplex > /dev/null 2>&1
echo "Old version removed."

# 2. Download the new version
echo "[2/4] Downloading latest IPK from GitHub..."
URL="https://github.com/azroukarim/starplex/raw/refs/heads/main/enigma2-plugin-extensions-starplex_v1.0_all.ipk"
IPK_TMP="/tmp/starplex_install.ipk"

wget -q --show-progress -O $IPK_TMP $URL

if [ ! -f $IPK_TMP ]; then
    echo "[-] Error: Failed to download the file. Please check your internet connection or URL."
    exit 1
fi

# 3. Install the plugin
echo "[3/4] Installing Starplex Plugin..."
opkg install --force-reinstall --force-overwrite $IPK_TMP

# 4. Clean up and restart GUI
echo "[4/4] Cleaning up..."
rm -f $IPK_TMP

echo "=========================================================="
echo "       Starplex Plugin Installed Successfully!          "
echo "       Enigma2 GUI will restart in 3 seconds...         "
echo "=========================================================="
sleep 3
killall -9 enigma2
