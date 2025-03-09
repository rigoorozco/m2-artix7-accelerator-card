#! /bin/sh

set -e

# Check the number of arguments
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <bitstream>"
    exit 1
fi

SCRIPT_DIR=$(dirname "$0")
PARTIAL_BITSTREAM=$1

# Check if bitstream exits
if [ ! -f ${PARTIAL_BITSTREAM} ]; then
    echo "Bitstream ${PARTIAL_BITSTREAM} not found!"
    exit 1
fi

# Addresses
DFX_DECOUPLER_DISCONNECT_REG=0x2000
DFX_DECOUPLER_STATUS_REG=0x2008
HWICAP_BASE_ADDR=0x1000

# Disconnect partition
OUTPUT=$(sh -c "${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user ${DFX_DECOUPLER_DISCONNECT_REG} w 1")

# Load partial bistream
${SCRIPT_DIR}/../../hwicap_write_bitstream/hwicap_write_bitstream /dev/xdma0_user ${HWICAP_BASE_ADDR} ${PARTIAL_BITSTREAM}

# Re-connect partition
OUTPUT=$(sh -c "${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user ${DFX_DECOUPLER_DISCONNECT_REG} w 0")

# Read status
OUTPUT=$(sh -c "${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user ${DFX_DECOUPLER_STATUS_REG} w | tail -c 11")
echo "Decoupler status is ${OUTPUT} after loading bitstream"
