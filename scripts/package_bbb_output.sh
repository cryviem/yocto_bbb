# To pack the output
# This script assume:
#   Run on root: yocto_bbb
#   Machine is beaglebone-yocto
#   Image is joe-image-full

YOCTO_BBB=`pwd`
MACHINE=beaglebone-yocto
IMAGE_DIR=${YOCTO_BBB}/build/tmp/deploy/images/${MACHINE}

SBL=MLO
UBOOT=u-boot.img
KERNEL=zImage
DTB=am335x-boneblack.dtb
ROOTFS=joe-image-full-beaglebone-yocto.tar.bz2
MODULES=modules-beaglebone-yocto.tgz

show_error() {
    echo "---- This script has some limitations ---"
    echo "  Must run on root: yocto_bbb"
    echo "  Machine is beaglebone-yocto only"
    echo "  Image is joe-image-full only"
    echo "-----------------------------------------"
}

if [ ! -d ${IMAGE_DIR} ]
then
    echo "${IMAGE_DIR} not found!"
    show_error
    exit 1
fi


if [ ! -f ${IMAGE_DIR}/${SBL} ]
then
    echo "${IMAGE_DIR}/${SBL} not found"
    show_error
    exit 1
fi

if [ ! -f ${IMAGE_DIR}/${UBOOT} ]
then
    echo "${IMAGE_DIR}/${UBOOT} not found"
    show_error
    exit 1
fi

if [ ! -f ${IMAGE_DIR}/${KERNEL} ]
then
    echo "${IMAGE_DIR}/${KERNEL} not found"
    show_error
    exit 1
fi

if [ ! -f ${IMAGE_DIR}/${DTB} ]
then
    echo "${IMAGE_DIR}/${DTB} not found"
    show_error
    exit 1
fi

if [ ! -f ${IMAGE_DIR}/${ROOTFS} ]
then
    echo "${IMAGE_DIR}/${ROOTFS} not found"
    show_error
    exit 1
fi

if [ ! -f ${IMAGE_DIR}/${MODULES} ]
then
    echo "${IMAGE_DIR}/${MODULES} not found"
    show_error
    exit 1
fi

# Make fresh output directory
rm -rf output
mkdir -p output/BOOT
mkdir -p output/ROOTFS
BOOT_DIR=${YOCTO_BBB}/output/BOOT
ROOTFS_DIR=${YOCTO_BBB}/output/ROOTFS

update_boot() {
    echo "coping $1 ..."
    # then copy over
    cp ${IMAGE_DIR}/$1 ${BOOT_DIR}
}

update_rootfs() {
    echo "coping rootfs ..."
    # then extract over
    tar -xvf ${IMAGE_DIR}/${ROOTFS} -C ${ROOTFS_DIR}
    tar -xvf ${IMAGE_DIR}/${MODULES} -C ${ROOTFS_DIR}
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
echo "Finish copying!"
echo "Zipping..."
rm -f bbb_output.tar.gz
sudo tar -cvz -f bbb_output.tar.gz output/
echo "All done!"