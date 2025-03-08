#! /bin/sh

# remove xilinx card and unload kernel driver module
sh -c "echo 1 > /sys/bus/pci/devices/0000:02:00.0/remove"
rmmod xdma
