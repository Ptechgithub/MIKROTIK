#!/bin/bash

# Check disk type
if lsblk | grep -q '/dev/sda'; then
    DISK="/dev/sda"
elif lsblk | grep -q '/dev/vda'; then
    DISK="/dev/vda"
elif lsblk | grep -q '/dev/sdb'; then
    DISK="/dev/sdb"
elif lsblk | grep -q '/dev/sdc'; then
    DISK="/dev/sdc"
else
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
echo " Installed, rebooting, please wait..."
sudo echo b > /proc/sysrq-trigger
