SUMMARY = "joe apps init"
DESCRIPTION = "${SUMMARY}"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:append := ":${THISDIR}/files"

SRC_URI += " \
            file://joe_apps.init \
            "

inherit update-rc.d

INITSCRIPT_NAME = "joe_apps.init"
INITSCRIPT_PARAMS = "start 60 S ."

do_install() {
    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${WORKDIR}/${INITSCRIPT_NAME} ${D}${sysconfdir}/init.d/${INITSCRIPT_NAME}
}