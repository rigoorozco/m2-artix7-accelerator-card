#! /bin/sh

SCRIPT_DIR=$(dirname "$0")

# install new module into kernel (must have been compiled and installed to extras)
insmod ${SCRIPT_DIR}/../../xdma-kernel-module/xdma/xdma.ko interrupt_mode=0

# rescan PCI bus to install driver for this card
sh -c "echo 1 > /sys/bus/pci/rescan"
