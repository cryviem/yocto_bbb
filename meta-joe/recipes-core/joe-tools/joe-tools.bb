SUMMARY = "joe tools"
DESCRIPTION = "${SUMMARY}"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:append := ":${THISDIR}/files"

SRC_URI += " \
            file://firmware_update.sh \
            file://firmware_confirm.sh \
            file://joe_tools.init \
            "

FILES:${PN} += "/joe"

inherit update-rc.d

INITSCRIPT_NAME = "joe_tools.init"
INITSCRIPT_PARAMS = "start 99 S ."

do_install() {
    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${WORKDIR}/${INITSCRIPT_NAME} ${D}${sysconfdir}/init.d/${INITSCRIPT_NAME}
    install -d ${D}${JOE_INSTALL_SCRIPTS}
    install -m 0755 ${WORKDIR}/firmware_update.sh ${D}${JOE_INSTALL_SCRIPTS}
    install -m 0755 ${WORKDIR}/firmware_confirm.sh ${D}${JOE_INSTALL_SCRIPTS}
}