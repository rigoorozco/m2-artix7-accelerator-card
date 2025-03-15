#! /bin/sh

set -e

SCRIPT_DIR=$(dirname "$0")

${SCRIPT_DIR}/../../xdma-tools/dma_to_device \
    -d /dev/xdma0_h2c_0 \
    -f data/datafile0_4K.bin \
    -s 4096 \
    -a 0x1000 \
    -c 1
