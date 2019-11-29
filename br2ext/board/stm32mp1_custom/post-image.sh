#!/bin/bash

set -e

BOARD_DIR="$(dirname $0)"
GENIMAGE_CFG="${BOARD_DIR}/genimage.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"
SD_IMAGE_FS="${BINARIES_DIR}/sd_image_fs"

fs_extra_size=2000

ln -fs ${BOARD_DIR}/fit.its  /${BINARIES_DIR}/fit.its

mkimage -f ${BINARIES_DIR}/fit.its ${BINARIES_DIR}/fit.itb


if [ ! -d "${SD_IMAGE_FS}" ]
   then mkdir ${SD_IMAGE_FS}
   else rm -rf ${SD_IMAGE_FS}/*
fi
cp ${BINARIES_DIR}/fit.itb ${SD_IMAGE_FS}
size=$(du -s -L -B 1024 "${SD_IMAGE_FS}" | awk '{print $1}')
genext2fs -b $(( size+fs_extra_size )) -d "${SD_IMAGE_FS}" -U ${BINARIES_DIR}/fit.ext4
rm -rf "${SD_IMAGE_FS}"


rm -rf "${GENIMAGE_TMP}"

genimage                               \
	--rootpath "${TARGET_DIR}"     \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BINARIES_DIR}"  \
	--outputpath "${BINARIES_DIR}" \
	--config "${GENIMAGE_CFG}"
