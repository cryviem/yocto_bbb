SUMMARY = "joe example lib"
DESCRIPTION = "To build joe example lib"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"


SRC_URI = "git://github.com/cryviem/learngit.git;branch=master;protocol=https"
SRCREV = "34eb4ee75c77933cb4ca978a766304b1df5d1e8f"

python do_display_banner() {
    bb.plain("***********************************************");
    bb.plain("*                                             *");
    bb.plain("*  META-JOE > build jlib ...                  *");
    bb.plain("*                                             *");
    bb.plain("***********************************************");
}
addtask display_banner before do_build

S := "${WORKDIR}/git/jmath"

do_compile() {
    ${CC} ${LDFLAGS} -c jmath.c -o jmath.o
    ${AR} rcs libjmath.a jmath.o
}

do_install() {
    install -d ${D}${libdir}
    install -m 0644 libjmath.a ${D}${libdir}

    install -d ${D}${includedir}
    install -m 0644 jmath.h ${D}${includedir}
}