#!/bin/sh

BOOT_DEV=/dev/mmcblk0p1
BOOT_DIR=/media/bootinfo
CUR_SLOT_PATH=${BOOT_DIR}/current_slot.txt
TRY_SLOT_PATH=${BOOT_DIR}/try_slot.txt
TRY_COUNT_PATH=${BOOT_DIR}/try_count.txt

KERNEL_A_DEV=/dev/mmcblk0p2
KERNEL_B_DEV=/dev/mmcblk0p3
ROOTFS_A_DEV=/dev/mmcblk0p5
ROOTFS_B_DEV=/dev/mmcblk0p6
USERDATA_DEV=/dev/mmcblk0p7

OTA_KERNEL_DIR=/media/kernel
OTA_ROOTFS_DIR=/media/rootfs

WORK_DIR=/data/firmware_update/tmp
KERNEL_ARCHIVE=${WORK_DIR}/bbb_kernel.tar.gz
ROOTFS_ARCHIVE=${WORK_DIR}/bbb_rootfs.tar.gz

CUR_SLOT_VALUE=not_set
TRY_SLOT_VALUE=not_set
TRY_COUNT_VALUE=0

mount_bootinfo() {
        echo "Mounting ${BOOT_DEV}"
        if [ ! -d "${BOOT_DIR}" ]; then
                mkdir -p ${BOOT_DIR}
        fi

        if [ "$(findmnt -n -o SOURCE ${BOOT_DIR})" != "${BOOT_DEV}" ]; then
                umount ${BOOT_DIR} 2>/dev/null
                mount ${BOOT_DEV} ${BOOT_DIR} || fail_exit "failed to mount bootinfo partition"
        fi        
}

umount_bootinfo() {
        echo "Unmounting ${BOOT_DEV}"
        umount ${BOOT_DIR} 2>/dev/null
}

mount_ota_slot() {
        local SLOT=$1
        echo "Mounting ${SLOT}"
        mkdir -p ${OTA_KERNEL_DIR} 
        mkdir -p ${OTA_ROOTFS_DIR}

        umount ${OTA_KERNEL_DIR} 2>/dev/null
        umount ${OTA_ROOTFS_DIR} 2>/dev/null

        if [ "${SLOT}" = "a" ]; then
                mount ${KERNEL_A_DEV} ${OTA_KERNEL_DIR} || fail_exit "failed to mount kernel partition"
                mount ${ROOTFS_A_DEV} ${OTA_ROOTFS_DIR} || fail_exit "failed to mount rootfs partition"
        elif [ "${SLOT}" = "b" ]; then
                mount ${KERNEL_B_DEV} ${OTA_KERNEL_DIR} || fail_exit "failed to mount kernel partition"
                mount ${ROOTFS_B_DEV} ${OTA_ROOTFS_DIR} || fail_exit "failed to mount rootfs partition"
        else
                fail_exit "invalid slot: ${SLOT}"
        fi
}

umount_ota_slot() {
        echo "Unmounting ${OTA_KERNEL_DIR} and ${OTA_ROOTFS_DIR}"
        umount ${OTA_KERNEL_DIR} 2>/dev/null
        umount ${OTA_ROOTFS_DIR} 2>/dev/null
}

get_ota_info() {
        if [ -f "${CUR_SLOT_PATH}" ]; then
                CUR_SLOT_VALUE=$(sed -n 's/^ota_cur_slot=//p' ${CUR_SLOT_PATH})
        fi

        if [ -f "${TRY_SLOT_PATH}" ]; then
                TRY_SLOT_VALUE=$(sed -n 's/^ota_try_slot=//p' ${TRY_SLOT_PATH})
        fi

        if [ -f "${TRY_COUNT_PATH}" ]; then
                TRY_COUNT_VALUE=$(sed -n 's/^ota_try_count=//p' ${TRY_COUNT_PATH})
        fi

        echo "OTA Info: cur_slot: ${CUR_SLOT_VALUE}, try_slot: ${TRY_SLOT_VALUE}, try_count: ${TRY_COUNT_VALUE}"

}

find_ota_slot() {

        if [ "${TRY_SLOT_VALUE}" = "a" ] || [ "${TRY_SLOT_VALUE}" = "b" ] ; then
                fail_exit "try_slot occupied: ${TRY_SLOT_VALUE}"
        fi

        local ROOT_MOUNTED=$(findmnt -n -o SOURCE /)

        if [ "${CUR_SLOT_VALUE}" = "a" ] && [ "${ROOT_MOUNTED}" = "${ROOTFS_A_DEV}" ]; then
                TRY_SLOT_VALUE=b
                TRY_COUNT_VALUE=0
        elif [ "${CUR_SLOT_VALUE}" = "b" ] && [ "${ROOT_MOUNTED}" = "${ROOTFS_B_DEV}" ]; then
                TRY_SLOT_VALUE=a
                TRY_COUNT_VALUE=0
        else
                fail_exit "cur_slot is invalid: ${CUR_SLOT_VALUE} - root_mounted: ${ROOT_MOUNTED}"
        fi
        
        echo "try_slot: ${TRY_SLOT_VALUE}" 
}

fail_exit() {
        echo "Terminating due to error: $1"
        umount_bootinfo
        umount_ota_slot
        rm -rf ${WORK_DIR}
        exit 1
}

update_firmware() {
        local BUNDLE=$1
        echo "Extracting ${BUNDLE} file"

        mkdir -p ${WORK_DIR} || fail_exit "failed to create work directory"
        tar -xvf ${BUNDLE} -C ${WORK_DIR} || fail_exit "failed to extract bundle"

        if [ ! -f "${KERNEL_ARCHIVE}" ] || [ ! -f "${ROOTFS_ARCHIVE}" ]; then
                fail_exit "kernel or rootfs archive not found"
        fi

        echo "Updating kernel"
        rm -rf ${OTA_KERNEL_DIR}/*
        tar -xvf ${KERNEL_ARCHIVE} -C ${OTA_KERNEL_DIR} || fail_exit "failed to extract kernel archive"

        echo "Updating rootfs"
        rm -rf ${OTA_ROOTFS_DIR}/*
        tar -xvf ${ROOTFS_ARCHIVE} -C ${OTA_ROOTFS_DIR} || fail_exit "failed to extract rootfs archive"

        echo "Firmware update completed"
}

mark_success() {
        echo "Marking success"
        echo "ota_try_slot=${TRY_SLOT_VALUE}" > ${TRY_SLOT_PATH}
        echo "ota_try_count=${TRY_COUNT_VALUE}" > ${TRY_COUNT_PATH}
        sync
}

# --- ENTRY POINT ---
echo "--- FIRMWARE UPDATE SCRIPT ---"

BUNDLE_PATH=$1

if [ -z "${BUNDLE_PATH}" ]; then
        fail_exit "bundle path is not set"
fi

if [ ! -f "${BUNDLE_PATH}" ]; then
        fail_exit "bundle file not found: ${BUNDLE_PATH}"
fi

mount_bootinfo
get_ota_info
find_ota_slot
mount_ota_slot ${TRY_SLOT_VALUE}
update_firmware ${BUNDLE_PATH}
mark_success
umount_ota_slot
umount_bootinfo