#! /bin/sh

set -e

SCRIPT_DIR=$(dirname "$0")

# Put intial file here
START_ADDR=0x1000

# Put copy here
END_ADDR=0x2000

# Size of file
FILE_SIZE=4096

# Input file
INPUT_FILE=data/datafile0_4K.bin

# Output file
OUTPUT_FILE=data/output_datafile0_4K.bin

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
OFFSET_USR_RESET=0x0C
OFFSET_CMD_TAG=0x10
OFFSET_CMD_SADDR_HIGH=0x14
OFFSET_CMD_SADDR_LOW=0x18
OFFSET_CMD_DDR=0x1C
OFFSET_CMD_EOF=0x20
OFFSET_CMD_DSA=0x24
OFFSET_CMD_TYPE=0x28
OFFSET_CMD_BTT=0x2C
OFFSET_STS_WORD=0x30

################################
# Load test file into DDR
################################

${SCRIPT_DIR}/../../xdma-tools/dma_to_device \
    -d /dev/xdma0_h2c_0 \
    -f ${INPUT_FILE} \
    -s ${FILE_SIZE} \
    -a ${START_ADDR} \
    -c 1

################################
# MM2S CONFIG
################################

# Configure MM2S datamover address
${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user \
    $(( MM2S_BASE_ADDR + OFFSET_CMD_SADDR_LOW )) \
    w ${START_ADDR}

# Configure MM2S datamover size
${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user \
    $(( MM2S_BASE_ADDR + OFFSET_CMD_BTT )) \
    w ${FILE_SIZE}

# Configure MM2S datamover EOF
${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user \
    $(( MM2S_BASE_ADDR + OFFSET_CMD_EOF )) \
    w 0x1

# Configure MM2S datamover type INCR
${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user \
    $(( MM2S_BASE_ADDR + OFFSET_CMD_TYPE )) \
    w 0x1

################################
# S2MM CONFIG
################################

# Configure MM2S datamover address
${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user \
    $(( S2MM_BASE_ADDR + OFFSET_CMD_SADDR_LOW )) \
    w ${END_ADDR}

# Configure MM2S datamover size
${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user \
    $(( S2MM_BASE_ADDR + OFFSET_CMD_BTT )) \
    w ${FILE_SIZE}

# Configure MM2S datamover EOF
${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user \
    $(( S2MM_BASE_ADDR + OFFSET_CMD_EOF )) \
    w 0x1

# Configure MM2S datamover type INCR
${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user \
    $(( S2MM_BASE_ADDR + OFFSET_CMD_TYPE )) \
    w 0x1

# Enable MM2S datamover
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

# Read S2MM datamover status word
${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user \
    $(( S2MM_BASE_ADDR + OFFSET_STS_WORD ))

# Read MM2S datamover status word
${SCRIPT_DIR}/../../xdma-tools/reg_rw /dev/xdma0_user \
    $(( MM2S_BASE_ADDR + OFFSET_STS_WORD ))

################################
# Retrieve test file from DDR
################################

${SCRIPT_DIR}/../../xdma-tools/dma_from_device \
    -d /dev/xdma0_c2h_0 \
    -f ${OUTPUT_FILE} \
    -s ${FILE_SIZE} \
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
