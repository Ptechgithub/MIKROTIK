#!/bin/bash

# Install necessary packages (if not already installed)
echo "Updating package list..."
sudo apt-get update -y
echo "Installing wget..."
sudo apt-get install -y wget
echo "Installing coreutils..."
sudo apt-get install -y coreutils

# Find the root partition
ROOT_PARTITION=$(sudo mount | grep 'on / type' | awk '{ print $1 }' | sed 's/[0-9]*$//')

if [[ -z "$ROOT_PARTITION" ]]; then
    echo "Error: Root partition not found"
    exit 1
fi

# Check disk type
if [[ "$ROOT_PARTITION" == *nvme* ]]; then
    BLOCK_SIZE=512
else
    BLOCK_SIZE=1024
fi

# Download and install CHR image on disk
sudo wget https://download.mikrotik.com/routeros/7.11.2/chr-7.11.2.img.zip -O chr.img.zip
gunzip -c chr.img.zip > chr.img
read -p "Press Enter to continue..."
echo u > /proc/sysrq-trigger
dd if=chr.img bs=$BLOCK_SIZE of="$ROOT_PARTITION"
echo "sync disk"
echo s > /proc/sysrq-trigger
echo "please wait ..."
sleep 5
echo "Installed, rebooting..."
echo b > /proc/sysrq-trigger
