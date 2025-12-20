FILESEXTRAPATHS:append := ":${THISDIR}/files"
SRC_URI += "file://joe_do_nothing.cfg file://0001-add-joe-module.patch file://am335x-boneblack-joe.dts"

# Copy custom device tree to kernel source before compilation
do_configure:prepend() {
    cp ${WORKDIR}/am335x-boneblack-joe.dts ${S}/arch/arm/boot/dts/
}

KERNEL_DEVICETREE:append = " am335x-boneblack-joe.dtb"
