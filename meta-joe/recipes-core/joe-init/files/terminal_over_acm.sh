#!/bin/sh

ACM_DEVICE=/dev/ttyGS0
for i in $(seq 1 10); do
    if [ -c $ACM_DEVICE ]; then
        getty -L $ACM_DEVICE 115200 vt100
        exit 0
    fi
    sleep 1
done

echo "$ACM_DEVICE not found"
exit 1