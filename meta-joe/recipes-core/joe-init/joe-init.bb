SUMMARY = "joe init script"
DESCRIPTION = "${SUMMARY}"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:append := ":${THISDIR}/files"

SRC_URI += " \
            file://setup_usb_gadget.sh \
            file://clean_usb_gadget.sh \
            file://terminal_over_acm.sh \
            file://mini_usb.init \
            "

FILES:${PN} += "/joe"

inherit update-rc.d

INITSCRIPT_NAME = "mini_usb.init"
INITSCRIPT_PARAMS = "start 50 S ."

do_install() {
    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${WORKDIR}/mini_usb.init ${D}${sysconfdir}/init.d/${INITSCRIPT_NAME}
    install -d ${D}${JOE_INSTALL_SCRIPTS}
    install -m 0775 ${WORKDIR}/setup_usb_gadget.sh ${D}${JOE_INSTALL_SCRIPTS}
    install -m 0775 ${WORKDIR}/clean_usb_gadget.sh ${D}${JOE_INSTALL_SCRIPTS}
    install -m 0775 ${WORKDIR}/terminal_over_acm.sh ${D}${JOE_INSTALL_SCRIPTS}
}