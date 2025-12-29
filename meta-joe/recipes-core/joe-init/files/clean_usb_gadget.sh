#!/bin/sh

CFGFS=/sys/kernel/config
USBGADGET=$CFGFS/usb_gadget
G=$USBGADGET/g1
G1_CFG=$G/configs/c.1
G1_FUNC=$G/functions

[ ! -d "$USBGADGET" ] && echo "$USBGADGET not found" && exit 0
[ ! -d "$G" ] && echo "$G not found" && exit 0

# Unbind the gadget from UDC first
echo "" > $G/UDC

# Remove function symlinks from config (these are symlinks, use rm)
rm $G1_CFG/acm.usb0
rm $G1_CFG/ecm.usb0

# Remove config strings directory (use rmdir for configfs dirs)
rmdir $G1_CFG/strings/0x409

# Remove config directory
rmdir $G1_CFG

# Remove function instances (use rmdir)
rmdir $G1_FUNC/acm.usb0
rmdir $G1_FUNC/ecm.usb0

# Remove gadget strings
rmdir $G/strings/0x409

# Remove gadget
rmdir $G
