#!/bin/sh
HERE=`dirname $0`
HERE=`realpath $HERE`
OUTPUT="$HERE/plc49.bin"
ENV="$HERE/nodemcu-env"
FSDIR="$HERE/rootfs"

PLC49_FLASH_SIZE=1048576
# >20% reduced HTTP request time compared to 40MHz
PLC49_FLASH_SPEED_MHZ=80
FILE_0="$ENV/nodemcu-firmware/bin/0x00000.bin"
FILE_1="$ENV/nodemcu-firmware/bin/0x10000.bin"
MKSPIFFS="$ENV/mkspiffs/mkspiffs"
MKSPIFFS_TO_FIT="$ENV/mkspiffs-to-fit.sh"

$HERE/build-image.sh \
    "$OUTPUT" "$PLC49_FLASH_SIZE" "$PLC49_FLASH_SPEED_MHZ" "$FSDIR" "$MKSPIFFS" "$MKSPIFFS_TO_FIT" \
    0 "$FILE_0" \
    65536 "$FILE_1" \
