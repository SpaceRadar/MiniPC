#!/bin/sh

BOARD_DIR="$(dirname $0)"

if [ -x /usr/bin/hg ] && [ -d ${BR2_EXTERNAL_EURECA_TREE_PATH}/../.hg ]; then
    hg id > ${TARGET_DIR}/etc/firmware_rev
fi
