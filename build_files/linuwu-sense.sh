#!/bin/bash
# build-linuwu-sense.sh - Integrate Linuwu-Sense into a Bazzite custom image

set -euo pipefail

LINUWU_SENSE_REPO="https://github.com/0x7375646F/Linuwu-Sense.git"
LINUWU_SENSE_DIR="/tmp/Linuwu-Sense"
KVER=$(rpm -q --queryformat="%{evr}.%{arch}" kernel-core)

echo "Integrating Linuwu-Sense into the image..."

# Clone the Linuwu-Sense repository
if [ ! -d "$LINUWU_SENSE_DIR" ]; then
    echo "Cloning Linuwu-Sense repository..."
    git clone "$LINUWU_SENSE_REPO" "$LINUWU_SENSE_DIR"
else
    echo "Using existing Linuwu-Sense directory."
fi

# Remove the entire signing block from the Makefile - it'll have issues with sudo
echo "Removing signing block from Makefile..."
sed -i '/# --- auto sign block ---/,/fi \\/d' "$LINUWU_SENSE_DIR/Makefile"

# Build the module
echo "Building and installing Linuwu-Sense..."
cd "$LINUWU_SENSE_DIR"
make

# Manually install the module
echo "Installing Linuwu-Sense module..."
mkdir -p /lib/modules/$KVER/extra
cp $LINUWU_SENSE_DIR/src/linuwu_sense.ko /lib/modules/$KVER/kernel/drivers/platform/x86
depmod -a

# Blacklist the stock acer_wmi module to prevent conflicts
echo "Blacklisting stock acer_wmi module..."
echo "blacklist acer_wmi" > /etc/modprobe.d/blacklist-acer_wmi.conf

# Enable the linuwu_sense module at boot
echo "Enabling linuwu_sense module at boot..."
echo "linuwu_sense" > /etc/modules-load.d/linuwu_sense.conf

# Clean up
cd ..
rm -rf "$LINUWU_SENSE_DIR"

echo "Linuwu-Sense integration complete."
