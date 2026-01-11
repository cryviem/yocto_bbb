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

        echo "Firmware Info: cur_slot: ${CUR_SLOT_VALUE}, try_slot: ${TRY_SLOT_VALUE}, try_count: ${TRY_COUNT_VALUE}"
}

check_root_mounted() {
        # Skip check if no pending firmware update
        if [ "${TRY_SLOT_VALUE}" != "a" ] && [ "${TRY_SLOT_VALUE}" != "b" ]; then
                echo "No pending firmware update (try_slot=${TRY_SLOT_VALUE}), skipping root mount check"
                return 0
        fi

        local STATUS=true
        local ROOT_MOUNTED=$(findmnt -n -o SOURCE /)
        
        if [ "${TRY_SLOT_VALUE}" = "a" ] && [ "${ROOT_MOUNTED}" != "${ROOTFS_A_DEV}" ]; then
                STATUS=false
        elif [ "${TRY_SLOT_VALUE}" = "b" ] && [ "${ROOT_MOUNTED}" != "${ROOTFS_B_DEV}" ]; then
                STATUS=false
        fi

        if [ "${STATUS}" = true ]; then
                echo "CHECK ROOT MOUNT PASSED > try_slot: ${TRY_SLOT_VALUE} - root_mounted: ${ROOT_MOUNTED}"
        else
                fail_exit "CHECK ROOT MOUNT FAILED > try_slot: ${TRY_SLOT_VALUE} - root_mounted: ${ROOT_MOUNTED}"
        fi
}

check_and_confirm() {

        # Todo: perform check here and exit if check failed

        check_root_mounted
        
        # At this point, we can confirm the firmware
        echo "Firmware check passed!"

        local UPDATE_NEEDED=false
        if [ "${TRY_SLOT_VALUE}" = "a" ] && [ "${CUR_SLOT_VALUE}" != "a" ]; then
                CUR_SLOT_VALUE=a
                TRY_SLOT_VALUE=not_set
                TRY_COUNT_VALUE=0
                UPDATE_NEEDED=true
        elif [ "${TRY_SLOT_VALUE}" = "b" ] && [ "${CUR_SLOT_VALUE}" != "b" ]; then
                CUR_SLOT_VALUE=b
                TRY_SLOT_VALUE=not_set
                TRY_COUNT_VALUE=0
                UPDATE_NEEDED=true
        else
                echo "try_slot is not set"
        fi

        if [ "${UPDATE_NEEDED}" = true ]; then
                echo "Set active slot to ${CUR_SLOT_VALUE}"
                echo "ota_cur_slot=${CUR_SLOT_VALUE}" > ${CUR_SLOT_PATH}
                echo "ota_try_slot=${TRY_SLOT_VALUE}" > ${TRY_SLOT_PATH}
                echo "ota_try_count=${TRY_COUNT_VALUE}" > ${TRY_COUNT_PATH}
                sync
        fi
}

fail_exit() {
        echo "Check failed: $1"
        umount_bootinfo
        exit 1
}

# --- ENTRY POINT ---
echo "--- FIRMWARE CONFIRM SCRIPT ---"

mount_bootinfo
get_ota_info
check_and_confirm
umount_bootinfo