SUMMARY = "derived from core-image-full-cmdline"

IMAGE_FEATURES += "splash ssh-server-openssh"

IMAGE_INSTALL = "\
    packagegroup-core-boot \
    packagegroup-core-full-cmdline \
    ${CORE_IMAGE_EXTRA_INSTALL} \
    "

inherit core-image

# Ensure boot-script is built and deployed alongside the image
do_image[depends] += "boot-script:do_deploy"