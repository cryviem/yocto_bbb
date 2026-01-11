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
DTB_JOE=am335x-boneblack-joe.dtb
BOOT_SCRIPT=boot.scr.uimg
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

if [ ! -f ${IMAGE_DIR}/${BOOT_SCRIPT} ]
then
    echo "${IMAGE_DIR}/${BOOT_SCRIPT} not found"
    show_error
    exit 1
fi
# Make fresh output directory

OUTPUT_DIR=${YOCTO_BBB}/output
BOOT_DIR=${OUTPUT_DIR}/BOOT
KERNEL_DIR=${OUTPUT_DIR}/KERNEL
ROOTFS_DIR=${OUTPUT_DIR}/ROOTFS

rm -rf ${OUTPUT_DIR}
mkdir -p ${BOOT_DIR}
mkdir -p ${KERNEL_DIR}
mkdir -p ${ROOTFS_DIR}

update_boot() {
    cp ${IMAGE_DIR}/${SBL} ${BOOT_DIR}
    cp ${IMAGE_DIR}/${UBOOT} ${BOOT_DIR}
    cp ${IMAGE_DIR}/${BOOT_SCRIPT} ${BOOT_DIR}
    tar -czf ${OUTPUT_DIR}/bbb_boot.tar.gz -C ${BOOT_DIR} .
}

update_kernel() {
    cp ${IMAGE_DIR}/${KERNEL} ${KERNEL_DIR}
    cp ${IMAGE_DIR}/${DTB} ${KERNEL_DIR}
    if [ -f ${IMAGE_DIR}/${DTB_JOE} ]
    then
        cp ${IMAGE_DIR}/${DTB_JOE} ${KERNEL_DIR}
    fi
    tar -czf ${OUTPUT_DIR}/bbb_kernel.tar.gz -C ${KERNEL_DIR} .
}

update_rootfs() {
    echo "coping rootfs ..."
    # then extract over
    sudo tar -xf ${IMAGE_DIR}/${ROOTFS} -C ${ROOTFS_DIR}
    sudo tar -xf ${IMAGE_DIR}/${MODULES} -C ${ROOTFS_DIR}
    sudo tar -czf ${OUTPUT_DIR}/bbb_rootfs.tar.gz -C ${ROOTFS_DIR} .
}

update_boot
update_kernel
update_rootfs

echo "Finish copying!"
echo "Zipping..."
tar -cvf ${OUTPUT_DIR}/bbb_bundle.tar -C ${OUTPUT_DIR} bbb_boot.tar.gz bbb_kernel.tar.gz bbb_rootfs.tar.gz
echo "All done!"