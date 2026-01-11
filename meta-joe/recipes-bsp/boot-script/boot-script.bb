SUMMARY = "Custom boot script which support A / B bank switching"
LICENSE = "CLOSED"

inherit allarch deploy

# We need mkimage on the build host
DEPENDS += "u-boot-tools-native"

FILESEXTRAPATHS:append := ":${THISDIR}/files"

SRC_URI = "file://boot-ota.txt"

# Use staging path to find native mkimage reliably
MKIMAGE = "${STAGING_BINDIR_NATIVE}/mkimage"

do_compile () {
    # Ensure the mkimage exists
    if [ ! -x "${MKIMAGE}" ]; then
        bbfatal "mkimage not found at ${MKIMAGE}. Ensure u-boot-tools-native is in DEPENDS."
    fi

    ${MKIMAGE} -A arm -T script -C none -n "U-Boot boot script" -d ${WORKDIR}/boot-ota.txt ${WORKDIR}/boot.scr.uimg
}

do_deploy () {
    install -d ${DEPLOYDIR}
    install -m 0644 ${WORKDIR}/boot.scr.uimg ${DEPLOYDIR}/boot.scr.uimg
}

addtask deploy after do_compile
