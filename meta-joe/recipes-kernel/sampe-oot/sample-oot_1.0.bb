SUMMARY = "Sample out of tree kernel modlue"
DESCRIPTION = "Sample out of tree kernel modlue"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# Add bitbake search path
# FILESEXTRAPATHS:append := ":${JOE_SRC}/${PN}"

SRC_URI = "file://choen.c  file://Makefile"

python do_display_banner() {
    bb.plain("***********************************************");
    bb.plain("*                                             *");
    bb.plain("*  META-JOE > build sample-oot ...        *");
    bb.plain("*                                             *");
    bb.plain("***********************************************");
}

addtask display_banner before do_build

S = "${WORKDIR}"

# Don't need specify do_compile since handled by cmake class
#do_compile() {
#	${CC} ${LDFLAGS} helloworld.c -o helloworld
#}

do_install() {
	install -d ${D}${bindir}
	install -m 0755 helloworld ${D}${bindir}
}