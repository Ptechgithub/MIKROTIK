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
echo "Starting CHR image download..."
sudo wget https://download.mikrotik.com/routeros/7.10/chr-7.10.img.zip -O chr.img.zip
read -p "Press Enter to continue .. "
sudo gunzip -c chr.img.zip > chr.img
sudo echo u > /proc/sysrq-trigger
echo "wait.."
sudo dd if=chr.img bs=$BLOCK_SIZE of="$ROOT_PARTITION"
read -p "Press Enter to continue .. "
echo "sync disk"
sudo echo s > /proc/sysrq-trigger
echo "Installing..."
read -p "Press Enter to continue .. "
echo "Installed, rebooting, please wait..."
sudo echo b > /proc/sysrq-trigger
