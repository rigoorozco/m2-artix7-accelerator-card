#! /bin/sh

set -e

SCRIPT_DIR=$(dirname "$0")

${SCRIPT_DIR}/../../xdma-tools/dma_from_device \
    -d /dev/xdma0_c2h_0 \
    -f data/output_datafile0_4K.bin \
    -s 4096 \
    -a 0x1000 \
    -c 1