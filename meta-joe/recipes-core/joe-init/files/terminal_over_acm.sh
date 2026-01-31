#!/bin/sh

ACM_DEV=ttyGS0
ACM_DEV_PATH=/dev/${ACM_DEV}

# Wait for device to appear
for i in $(seq 1 10); do
    if [ -c $ACM_DEV_PATH ]; then
        break
    fi
    sleep 1
done

if [ ! -c $ACM_DEV_PATH ]; then
    echo "$ACM_DEV_PATH not found"
    exit 1
fi

# Run getty in a respawn loop (background)
while true; do
    getty -L $ACM_DEV 115200 vt100
    sleep 1
done