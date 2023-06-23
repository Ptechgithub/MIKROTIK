#!/bin/bash

# Check disk type
if [ -e /dev/sda ]; then
    DISK="/dev/sda"
elif [ -e /dev/vda ]; then
    DISK="/dev/vda"
elif [ -e /dev/sdb ]; then
    DISK="/dev/sdb"
elif [ -e /dev/sdc ]; then
    DISK="/dev/sdc"
else
    echo "Error: Disk not found"
    exit 1
fi

# Download and install CHR image on disk
echo "Starting CHR image download..."
sleep 1
wget https://download.mikrotik.com/routeros/7.10/chr-7.10.img.zip -O chr.img.zip
read -p "Press Enter to continue .. "
gunzip -c chr.img.zip > chr.img
echo u > /proc/sysrq-trigger
echo "wait.."
sleep 1
dd if=chr.img bs=1024 of="$DISK"
read -p "Press Enter to continue .. "
echo "sync disk"
echo s > /proc/sysrq-trigger
echo "Installing..."
sleep 5
echo " Telegram :---> https://t.me/P_tech2024"
echo " Installed, rebooting, please wait..."
echo b > /proc/sysrq-trigger
