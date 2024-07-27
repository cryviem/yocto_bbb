SUMMARY = "hello world app"
DESCRIPTION = "Should be the very first thing here"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# Add bitbake search path
FILESEXTRAPATHS:append := ":${JOE_SRC}/${PN}"

SRC_URI = "file://helloworld.c  file://CMakeLists.txt"

DEPENDS := "jlib"

inherit cmake

python do_display_banner() {
    bb.plain("***********************************************");
    bb.plain("*                                             *");
    bb.plain("*  META-JOE > build helloworld app ...        *");
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