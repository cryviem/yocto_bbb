# Boot script for BeagleBone Black with OTA support
# To compile: mkimage -C none -A arm -T script -d boot_ota.cmd boot_ota.scr.uimg

# Configuration
setenv fdtfile "am335x-boneblack.dtb"
setenv BOOTINFO_PART "mmc 0:1"
setenv OPERATION_MODE_FILE "operation_mode.txt"
setenv OTA_CUR_SLOT_FILE "current_slot.txt"
setenv OTA_TRY_SLOT_FILE "try_slot.txt"
setenv OTA_TRY_COUNT_FILE "try_count.txt"
setenv KERNEL_A_PART "2"
setenv KERNEL_B_PART "3"
setenv ROOTFS_A_DEV "/dev/mmcblk0p5"
setenv ROOTFS_B_DEV "/dev/mmcblk0p6"
setenv DEFAULT_BOOT_SLOT "a"


# Load operation mode
# Output: ota_cur_slot
setenv load_operation_mode '\
    setenv loadaddr 0x82000000;\
    if fatload ${BOOTINFO_PART} ${loadaddr} ${OPERATION_MODE_FILE}; then\
        env import -t ${loadaddr} ${filesize};\
    fi;\
    if test "${operation_mode}" != "no-fallback" -a "${operation_mode}" != "fallback"; then\
        echo "Operation mode not set, set to default no-fallback";\
        setenv operation_mode "no-fallback";\
        env export -t ${loadaddr} operation_mode;\
        fatwrite ${BOOTINFO_PART} ${loadaddr} ${OPERATION_MODE_FILE} ${filesize};\
    else\
        echo "Operation mode: ${operation_mode}";\
    fi;\
    '

# Save current slot
# Input: ota_cur_slot
setenv save_current_slot '\
    setenv loadaddr 0x82000000;\
    env export -t ${loadaddr} ota_cur_slot;\
    fatwrite ${BOOTINFO_PART} ${loadaddr} ${OTA_CUR_SLOT_FILE} ${filesize};\
    '

# Load current slot
# Output: ota_cur_slot
setenv load_current_slot '\
    setenv loadaddr 0x82000000;\
    if fatload ${BOOTINFO_PART} ${loadaddr} ${OTA_CUR_SLOT_FILE}; then\
        env import -t ${loadaddr} ${filesize};\
    fi;\
    if test "${ota_cur_slot}" != "a" -a "${ota_cur_slot}" != "b" -a "${ota_cur_slot}" != "not_set"; then\
        setenv ota_cur_slot not_set;\
        run save_current_slot;\
    fi;\
    '

# Save try slot
# Input: ota_try_slot
setenv save_try_slot '\
    setenv loadaddr 0x82000000;\
    env export -t ${loadaddr} ota_try_slot;\
    fatwrite ${BOOTINFO_PART} ${loadaddr} ${OTA_TRY_SLOT_FILE} ${filesize};\
    '

# Load try slot
# Output: ota_try_slot
setenv load_try_slot '\
    setenv loadaddr 0x82000000;\
    if fatload ${BOOTINFO_PART} ${loadaddr} ${OTA_TRY_SLOT_FILE}; then\
        env import -t ${loadaddr} ${filesize};\
    fi;\
    if test "${ota_try_slot}" != "a" -a "${ota_try_slot}" != "b" -a "${ota_try_slot}" != "not_set"; then\
        setenv ota_try_slot not_set;\
        run save_try_slot;\
    fi;\
    '

# Save try count
# Input: ota_try_count
setenv save_try_count '\
    setenv loadaddr 0x82000000;\
    env export -t ${loadaddr} ota_try_count;\
    fatwrite ${BOOTINFO_PART} ${loadaddr} ${OTA_TRY_COUNT_FILE} ${filesize};\
    '

# Load try count
# Output: ota_try_count
setenv load_try_count '\
    setenv loadaddr 0x82000000;\
    if fatload ${BOOTINFO_PART} ${loadaddr} ${OTA_TRY_COUNT_FILE}; then\
        env import -t ${loadaddr} ${filesize};\
    fi;\
    if test "${ota_try_count}" != "1" -a "${ota_try_count}" != "2" -a "${ota_try_count}" != "3" -a "${ota_try_count}" != "0"; then\
        setenv ota_try_count 0;\
        run save_try_count;\
    fi;\
    '

# On failure action
# Depends on: operation_mode
setenv on_failure_action '\
    if test "${operation_mode}" = "no-fallback"; then\
        echo "Do reset ...";\
        reset;\
    else\
        echo "Do fallback to other method ...";\
        exit;\
    fi;\
    '


# Switch slot
# Input: switch_in
# Output: switch_out
setenv do_switch_slot '\
    if test "${switch_in}" = "a"; then\
        setenv switch_out b;\
    elif test "${switch_in}" = "b"; then\
        setenv switch_out a;\
    else\
        setenv switch_out not_set;\
    fi;\
    '

# Do zImage Booting
# Depends on:
# part_num: partition number containing the zImage and device tree
# root_dev: rootfs partition
setenv do_bootz '\
    setenv loadaddr 0x82000000;\
    setenv fdtaddr 0x88000000;\
    setenv bootargs "console=ttyO0,115200n8 root=${root_dev} rw rootfstype=ext4 rootwait";\
    echo "Loading kernel from mmc 0:${part_num} to ${loadaddr} ...";\
    if load mmc 0:${part_num} ${loadaddr} zImage; then\
        true;\
    else\
        run on_failure_action;\
    fi;\
    echo "Loading device tree from mmc 0:${part_num} to ${fdtaddr} ...";\
    if load mmc 0:${part_num} ${fdtaddr} ${fdtfile}; then\
        true;\
    else\
        run on_failure_action;\
    fi;\
    echo "Booting kernel from ${loadaddr} - ${fdtaddr} ...";\
    if bootz ${loadaddr} - ${fdtaddr}; then\
        true;\
    else\
        echo "BOOT FAILED!";\
        run on_failure_action;\
    fi;\
    '

setenv increment_try_count '\
    if test "${ota_try_count}" = "0"; then\
        setenv ota_try_count 1;\
    elif test "${ota_try_count}" = "1"; then\
        setenv ota_try_count 2;\
    elif test "${ota_try_count}" = "2"; then\
        setenv ota_try_count 3;\
    fi;\
    '

# Prepare the environment for do_bootz
# Depends on:
# boot_slot: slot [a, b]
setenv do_prepare '\
    if test "${boot_slot}" = "a"; then\
        setenv part_num ${KERNEL_A_PART};\
        setenv root_dev ${ROOTFS_A_DEV};\
    elif test "${boot_slot}" = "b"; then\
        setenv part_num ${KERNEL_B_PART};\
        setenv root_dev ${ROOTFS_B_DEV};\
    else\
        echo "Invalid boot slot: ${boot_slot}!";\
        run on_failure_action;\
    fi;\
    echo "Prepare to boot from slot: ${boot_slot}";\
    '

# Get boot slot
# Depends on: load_current_slot, load_try_slot, load_try_count
# Output: boot_slot
setenv do_get_slot '\
    run load_current_slot;\
    run load_try_slot;\
    run load_try_count;\

    echo "Before > Current slot: ${ota_cur_slot}, Try slot: ${ota_try_slot}, Try count: ${ota_try_count}";\

    if test "${ota_cur_slot}" != "a" -a "${ota_cur_slot}" != "b"; then\
        if test "${ota_try_slot}" != "a" -a "${ota_try_slot}" != "b"; then\
            echo "No active slot, try slot ${DEFAULT_BOOT_SLOT} first";\
            setenv ota_try_slot ${DEFAULT_BOOT_SLOT};\
            setenv boot_slot ${ota_try_slot};\
            setenv ota_try_count 1;\
        else\
            if test "${ota_try_count}" = "0" -o "${ota_try_count}" = "1" -o "${ota_try_count}" = "2"; then\
                echo "No active slot, try slot ${ota_try_slot} - try count ${ota_try_count}";\
                setenv boot_slot ${ota_try_slot};\
                run increment_try_count;\
            else\
                echo "No active slot, slot ${ota_try_slot} trying reached limit, switch to next slot";\
                setenv switch_in ${ota_try_slot};\
                run do_switch_slot;\
                setenv ota_try_slot ${switch_out};\
                setenv boot_slot ${ota_try_slot};\
                setenv ota_try_count 0;\
            fi;\
        fi;\
        run save_try_slot;\
        run save_try_count;\
    else\
        if test "${ota_try_slot}" = "a" -o "${ota_try_slot}" = "b"; then\
            if test "${ota_try_count}" = "0" -o "${ota_try_count}" = "1" -o "${ota_try_count}" = "2"; then\
                echo "OTA switching, try slot ${ota_try_slot} - try count ${ota_try_count}";\
                setenv boot_slot ${ota_try_slot};\
                run increment_try_count;\
            else\
                echo "OTA switching, slot ${ota_try_slot} reached limit, rollback to current slot ${ota_cur_slot}";\
                setenv ota_try_slot not_set;\
                setenv ota_try_count 0;\
                setenv boot_slot ${ota_cur_slot};\
            fi;\
            run save_try_slot;\
            run save_try_count;\
        else\
            echo "Booting from current slot ${ota_cur_slot}";\
            setenv boot_slot ${ota_cur_slot};\
        fi;\
    fi;\

    echo "After > Current slot: ${ota_cur_slot}, Try slot: ${ota_try_slot}, Try count: ${ota_try_count}";\
    echo "Boot slot: ${boot_slot} ...";\
    '


echo "--------------------------------";
echo "CUSTOM BOOT SCRIPT";
echo "--------------------------------";
run load_operation_mode
run do_get_slot
run do_prepare
run do_bootz