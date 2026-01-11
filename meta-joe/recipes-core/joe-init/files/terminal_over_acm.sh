#!/bin/sh

ACM_DEVICE=/dev/ttyGS0

# Wait for device to appear
for i in $(seq 1 10); do
    if [ -c $ACM_DEVICE ]; then
        break
    fi
    sleep 1
done

if [ ! -c $ACM_DEVICE ]; then
    echo "$ACM_DEVICE not found"
    exit 1
fi

# Run getty in a respawn loop (background)
while true; do
    getty -L $ACM_DEVICE 115200 vt100
    sleep 1
done &