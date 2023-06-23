#!/bin/bash

# Define possible disk names
DISKS=("/dev/sda" "/dev/vda" "/dev/sdb" "/dev/sdc")

# Check disk type
DISK=""
for disk in "${DISKS[@]}"; do
    if lsblk | grep -q "$disk"; then
        DISK="$disk"
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
sleep 1
sudo dd if=chr.img bs=1024 of="$DISK"
read -p "Press Enter to continue .. "

# Sync disk and reboot system
echo "sync disk"
sudo echo s > /proc/sysrq-trigger
echo "Installing..."
echo " Installed, rebooting, please wait..."
sleep 5
read -p "Press Enter to continue .. "
sudo echo b > /proc/sysrq-trigger
