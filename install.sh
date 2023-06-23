#!/bin/bash

# Install necessary packages (if not already installed)
echo "Updating package list..."
sudo apt-get update -y
echo "Installing wget..."
sudo apt-get install -y wget
echo "Installing coreutils..."
sudo apt-get install -y coreutils

# Check disk type
for disk in sda vda sdb sdc; do
    if lsblk | grep -q "/dev/$disk"; then
        DISK="/dev/$disk"
        break
    fi
done

if [ -z "$DISK" ]; then
    echo "Error: Disk not found"
    exit 1
fi

# Download and install CHR image on disk
echo "Starting CHR image download..."
sudo wget https://download.mikrotik.com/routeros/7.10/chr-7.10.img.zip -O chr.img.zip
read -p "Press Enter to continue .. "
sudo gunzip -c chr.img.zip > chr.img
sudo echo u > /proc/sysrq-trigger
echo "wait.."
sudo dd if=chr.img bs=1024 of="$DISK"
read -p "Press Enter to continue .. "
echo "sync disk"
sudo echo s > /proc/sysrq-trigger
echo "Installing..."
read -p "Press Enter to continue .. "
echo "Installed, rebooting, please wait..."
sudo echo b > /proc/sysrq-trigger
