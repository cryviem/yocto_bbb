set -e

CFGFS=/sys/kernel/config
USBGADGET=$CFGFS/usb_gadget
G=$USBGADGET/g1

depmod -a

modprobe configfs || true
mount none $CFGFS -t configfs || true

modprobe libcomposite || true

if [ ! -d "$USBGADGET" ]; then
  echo "USB gadget directory not found at $USBGADGET"
  exit 1
fi

[ -d "$G" ] && echo "gadget exists at $G, remove first if you want a fresh start" && exit 1

mkdir -p $G


# Set vendor and product id
echo 0x1d6b > $G/idVendor # Linux Foundation
echo 0x0104 > $G/idProduct # Multiple function gadget

# Set gadget info
mkdir -p $G/strings/0x409
echo "joe_manufacturer" > $G/strings/0x409/manufacturer
echo "joe_product" > $G/strings/0x409/product
echo "000000000023" > $G/strings/0x409/serialnumber

# Set configuration, those just to be shown as human readable description
mkdir -p $G/configs/c.1/strings/0x409
echo "joe default configuration" > $G/configs/c.1/strings/0x409/configuration

# Add ACM function
mkdir -p $G/functions/acm.usb0
ln -s $G/functions/acm.usb0 $G/configs/c.1

# Add ECM function
mkdir -p $G/functions/ecm.usb0
ln -s $G/functions/ecm.usb0 $G/configs/c.1

# Bind to the first UDC available
udc=$(ls /sys/class/udc | head -n1)
if [ -z "$udc" ]; then
  echo "No UDC found in /sys/class/udc — cannot bind gadget"
  exit 1
fi

echo $udc > $G/UDC

echo "Gadget setup complete"
