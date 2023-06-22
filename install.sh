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
wget https://download.mikrotik.com/routeros/7.10/chr-7.10.img.zip -O chr.img.zip
gunzip -c chr.img.zip > chr.img
echo u > /proc/sysrq-trigger
dd if=chr.img bs=1024 of="$DISK"
echo "sync disk"
echo s > /proc/sysrq-trigger
echo "Sleep 3 seconds"
sleep 3
echo "Ok, reboot please wait..."
echo b > /proc/sysrq-trigger
