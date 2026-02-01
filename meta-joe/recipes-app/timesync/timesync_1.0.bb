SUMMARY = "timesync service"
DESCRIPTION = "timesync service"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# Add bitbake search path
FILESEXTRAPATHS:append := ":${JOE_SRC}"

SRC_URI = "file://${BPN}"

inherit joe-cmake

python do_display_banner() {
    bb.plain("***********************************************");
    bb.plain("*                                             *");
    bb.plain("*  META-JOE > build ${BPN} app ...        *");
    bb.plain("*                                             *");
    bb.plain("***********************************************");
}

addtask display_banner before do_build

S = "${WORKDIR}/${BPN}"

do_install() {
	install -d ${D}${JOE_INSTALL_BIN}
	install -m 0755 ${BPN} ${D}${JOE_INSTALL_BIN}
}

FILES:${PN} += "${JOE_INSTALL_BIN}"