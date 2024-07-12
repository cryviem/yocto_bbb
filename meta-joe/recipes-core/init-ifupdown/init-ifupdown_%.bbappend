# This intend to override meta/recipes-core/init-ifupdown package
# Use our custom for /etc/network/interfaces 

# replace original file with any found in THISDIR/files
FILESEXTRAPATHS:append := ":${THISDIR}/files:"