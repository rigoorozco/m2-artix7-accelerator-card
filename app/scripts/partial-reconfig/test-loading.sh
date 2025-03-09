#! /bin/sh

set -e

SCRIPT_DIR=$(dirname "$0")

DFX_GPIO_CH2_REG=0x12008

# Write something
OUTPUT=$(sh -c "${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user ${DFX_GPIO_CH2_REG} w 0x0badf00d")

# Read value back
OUTPUT=$(sh -c "${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user ${DFX_GPIO_CH2_REG} w | tail -c 11")
echo "Wrote ${OUTPUT} to register"

# Load partial bitstream
${SCRIPT_DIR}/load-partial-bitstream.sh ${SCRIPT_DIR}/../../../projects/xdma_ddr3_dfx/build/static/xdma_ddr3_dfx_pblock_rm_partial.bin

# Read current value
OUTPUT=$(sh -c "${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user ${DFX_GPIO_CH2_REG} w | tail -c 11")
echo "Register value afer loading partial bitstream: ${OUTPUT}"
