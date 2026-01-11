#!/bin/sh

for i in $(seq 1 10); do
    if ip link show | grep -q "usb0"; then
        ip addr flush dev usb0
        ip addr add 192.168.7.23/24 dev usb0
        ip link set usb0 up
        echo "usb0 set to 192.168.7.23/24"
        exit 0
    fi
    sleep 5
done

echo "usb0 not found"
exit 1