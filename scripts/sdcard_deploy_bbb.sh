# To deploy yocto output image to SDCARD

MOUNT_BASE=/media/andy
BOOT_DIR=${MOUNT_BASE}/BOOT
ROOTFS_DIR=${MOUNT_BASE}/ROOTFS
USB_DEV1=/dev/sda1
USB_DEV2=/dev/sda2

SBL=MLO
UBOOT=u-boot.img
KERNEL=zImage
DTB=am335x-boneblack.dtb
ROOTFS=core-image-minimal-beaglebone-yocto.tar.bz2

# Make sure we have sufficient images to go
if [ -z $1 ]
then
    echo "Please specify image directory"
    exit 1
fi

if [ ! -d $1 ]
then
    echo "$1 not found"
    exit 1
fi

IMAGE_DIR=$1

if [ ! -f ${IMAGE_DIR}/${SBL} ]
then
    echo "${IMAGE_DIR}/${SBL} not found"
    exit 1
fi

if [ ! -f ${IMAGE_DIR}/${UBOOT} ]
then
    echo "${IMAGE_DIR}/${UBOOT} not found"
    exit 1
fi

if [ ! -f ${IMAGE_DIR}/${KERNEL} ]
then
    echo "${IMAGE_DIR}/${KERNEL} not found"
    exit 1
fi

if [ ! -f ${IMAGE_DIR}/${DTB} ]
then
    echo "${IMAGE_DIR}/${DTB} not found"
    exit 1
fi

if [ ! -f ${IMAGE_DIR}/${ROOTFS} ]
then
    echo "${IMAGE_DIR}/${ROOTFS} not found"
    exit 1
fi

# Make sure sdcard is plugged and mounted properly
if [ ! -d "${BOOT_DIR}" ]
then
    echo "${BOOT_DIR} does NOT exist, try mounting..."
    if [ -b ${USB_DEV1} ]
    then
        mount ${USB_DEV1} ${BOOT_DIR}
    fi

    if [ ! -d "${BOOT_DIR}" ]
    then
        echo "Can not mount, sorry..."
        exit 1
    fi
fi

if [ ! -d "${ROOTFS_DIR}" ]
then
    echo "${ROOTFS_DIR} does NOT exist, try mounting..."
    if [ -b ${USB_DEV2} ]
    then
        mount ${USB_DEV2} ${ROOTFS_DIR}
    fi

    if [ ! -d "${ROOTFS_DIR}" ]
    then
        echo "Can not mount, sorry..."
        exit 1
    fi
fi

update_boot() {
    echo "coping $1 ..."
    # first remove old
    rm -f ${BOOT_DIR}/$1
    # then copy over
    cp ${IMAGE_DIR}/$1 ${BOOT_DIR}
}

update_rootfs() {
    echo "coping rootfs ..."
    # first clean up
    rm -rf ${ROOTFS_DIR}/*
    # then extract over
    tar -xvf ${IMAGE_DIR}/${ROOTFS} -C ${ROOTFS_DIR}
}

unmount_sdcard() {
    umount ${BOOT_DIR}
    umount ${ROOTFS_DIR}
}

update_boot ${SBL}
update_boot ${UBOOT}
update_boot ${KERNEL}
update_boot ${DTB}
update_rootfs
echo "All done, wait a bit for syncing and un-mount SDCARD..."
sleep 1
sync
sleep 10
unmount_sdcard