FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += " file://fstab"

# Create /data mount point and add fstab entry
do_install:append() {
    # Create the /data mount point directory
    install -d ${D}/data
}

FILES:${PN} += "/data"
