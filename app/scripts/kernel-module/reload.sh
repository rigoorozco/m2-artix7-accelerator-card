#! /bin/sh

SCRIPT_DIR=$(dirname "$0")

# call other two scripts sequencially
${SCRIPT_DIR}/unload.sh
${SCRIPT_DIR}/load.sh
