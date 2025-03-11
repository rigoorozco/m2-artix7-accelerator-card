#! /bin/sh

# Get PCIe ID
ID=$(lspci -n -d 10ee: | cut -d ' ' -f 1)

# Exit if no ID is found
if [ -z "${ID}" ]; then
    exit 1
fi

# remove xilinx card and unload kernel driver module
sh -c "echo 1 > /sys/bus/pci/devices/0000:${ID}/remove"
rmmod xdma
