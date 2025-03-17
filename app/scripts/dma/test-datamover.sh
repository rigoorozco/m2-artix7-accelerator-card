#! /bin/sh

set -e

SCRIPT_DIR=$(dirname "$0")

# Put intial file here
START_ADDR=0x00000000

# Put copy here
END_ADDR=0x04000000

# Size of file
FILE_SIZE_MBYTES=64
FILE_SIZE_BYTES=$(( 1024 * 1024 * FILE_SIZE_MBYTES ))

# Size of a burst
BURST_SIZE=4096

# Make data directory
mkdir -p data

# Input file
INPUT_FILE=data/rand_32M.bin

# Output file
OUTPUT_FILE=data/output_rand_32M.bin

#
# NOTE:
# These base addresses correspond to default DFX BDC
#
MM2S_BASE_ADDR=0x10000
S2MM_BASE_ADDR=0x18000

#
# Configuration register offsets
#
OFFSET_USR_ENABLE=0x00
OFFSET_USR_AUTO_ENABLE=0x04
OFFSET_USR_SCRATCH=0x08
OFFSET_USR_BUFFER=0x0C
OFFSET_USR_LENTH=0x10
OFFSET_USR_BURST=0x14
OFFSET_CMD_TAG=0x18
OFFSET_CMD_DDR=0x1C
OFFSET_CMD_DSA=0x20
OFFSET_CMD_TYPE=0x24
OFFSET_STS_WORD=0x28
OFFSET_DBG_STATE=0x2C

################################
# Load test file into DDR
################################

dd if=/dev/random of=${INPUT_FILE} bs=1M count=${FILE_SIZE_MBYTES}

${SCRIPT_DIR}/../../xdma-tools/dma_to_device \
    -d /dev/xdma0_h2c_0 \
    -f ${INPUT_FILE} \
    -s ${FILE_SIZE_BYTES} \
    -a ${START_ADDR} \
    -c 1

################################
# MM2S CONFIG
################################

# Configure MM2S datamover address
${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user \
    $(( MM2S_BASE_ADDR + OFFSET_USR_BUFFER )) \
    w ${START_ADDR}

# Configure MM2S datamover size
${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user \
    $(( MM2S_BASE_ADDR + OFFSET_USR_LENTH )) \
    w ${FILE_SIZE_BYTES}

# Configure MM2S datamover burst size
${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user \
    $(( MM2S_BASE_ADDR + OFFSET_USR_BURST )) \
    w ${BURST_SIZE}

################################
# S2MM CONFIG
################################

# Configure S2MM datamover address
${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user \
    $(( S2MM_BASE_ADDR + OFFSET_USR_BUFFER )) \
    w ${END_ADDR}

# Configure S2MM datamover size
${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user \
    $(( S2MM_BASE_ADDR + OFFSET_USR_LENTH )) \
    w ${FILE_SIZE_BYTES}

# Configure S2MM datamover burst size
${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user \
    $(( S2MM_BASE_ADDR + OFFSET_USR_BURST )) \
    w ${BURST_SIZE}

# Enable S2MM datamover
${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user \
    $(( S2MM_BASE_ADDR + OFFSET_USR_ENABLE )) \
    w 0x1

################################
# MM2S Start
################################

# Enable MM2S datamover
${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user \
    $(( MM2S_BASE_ADDR + OFFSET_USR_ENABLE )) \
    w 0x1

################################
# Get status
################################

sleep 1

# Read S2MM datamover status word
${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user \
    $(( S2MM_BASE_ADDR + OFFSET_STS_WORD ))

# Read S2MM datamover state
${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user \
    $(( S2MM_BASE_ADDR + OFFSET_DBG_STATE ))

# Read MM2S datamover status word
${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user \
    $(( MM2S_BASE_ADDR + OFFSET_STS_WORD ))

# Read MM2S datamover state
${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user \
    $(( MM2S_BASE_ADDR + OFFSET_DBG_STATE ))

################################
# Retrieve test file from DDR
################################

sleep 1

${SCRIPT_DIR}/../../xdma-tools/dma_from_device \
    -d /dev/xdma0_c2h_0 \
    -f ${OUTPUT_FILE} \
    -s ${FILE_SIZE_BYTES} \
    -a ${END_ADDR} \
    -c 1

################################
# Compare files
################################
cmp ${INPUT_FILE} ${OUTPUT_FILE}
RESULT=$?

if [ ! ${RESULT} -eq 0 ]; then
    echo ""
    echo "DataMover test failed."
    exit 1
else
    echo ""
    echo "DataMover test succeeded!"
fi
