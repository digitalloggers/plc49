#!/bin/sh
HERE=`dirname $0`
HERE=`realpath $HERE`
OUTPUT="$1";shift
FLASH_SIZE="$1";shift
FLASH_SPEED_MHZ="$1";shift
FILESYSTEM="$1";shift
MKSPIFFS="$1";shift
MKSPIFFS_TO_FIT="$1";shift

dd bs="$FLASH_SIZE" count=1 if=/dev/zero | tr '\0' '\377' >"$OUTPUT"

SPIFFS=`mktemp`

while [ $# -gt 0 ]; do
    OFFSET="$1";shift
    FILENAME="$1";shift
    LATEST_OFFSET="$OFFSET"
    LATEST_FILENAME="$FILENAME"
    dd if="$FILENAME" of="$OUTPUT" seek="$OFFSET" bs=1 conv=notrunc
done
SPIFFS_OFFSET=`"$MKSPIFFS_TO_FIT" "$SPIFFS" "$FILESYSTEM" "$MKSPIFFS" "$FLASH_SIZE" "$LATEST_OFFSET" "$LATEST_FILENAME"`
dd if="$SPIFFS" of="$OUTPUT" seek="$SPIFFS_OFFSET" bs=1 conv=notrunc

# See flash_api.h, flash_api.c
FLASH_SPEED_NIBBLE=0 # default
if   [ $FLASH_SPEED_MHZ -eq 40 ]; then # 40MHz
    FLASH_SPEED_NIBBLE=0
elif [ $FLASH_SPEED_MHZ -eq 26 ]; then # 4Mbit
    FLASH_SPEED_NIBBLE=1
elif [ $FLASH_SPEED_MHZ -eq 20 ]; then # 8Mbit
    FLASH_SPEED_NIBBLE=2
elif [ $FLASH_SPEED_MHZ -eq 80 ]; then # 16Mbit
    FLASH_SPEED_NIBBLE=15
fi

echo $FLASH_SIZE
FLASH_SIZE_NIBBLE=0 # default
if   [ $FLASH_SIZE -eq $((256*1024))     ]; then # 2Mbit
    FLASH_SIZE_NIBBLE=1
elif [ $FLASH_SIZE -eq $((512*1024))     ]; then # 4Mbit
    FLASH_SIZE_NIBBLE=0
elif [ $FLASH_SIZE -eq $((1024*1024))    ]; then # 8Mbit
    FLASH_SIZE_NIBBLE=2
elif [ $FLASH_SIZE -eq $((2*1024*1024))  ]; then # 16Mbit
    FLASH_SIZE_NIBBLE=3
elif [ $FLASH_SIZE -eq $((4*1024*1024))  ]; then # 32Mbit
    FLASH_SIZE_NIBBLE=4
elif [ $FLASH_SIZE -eq $((8*1024*1024))  ]; then # 64Mbit
    FLASH_SIZE_NIBBLE=5
elif [ $FLASH_SIZE -eq $((16*1024*1024)) ]; then # 128Mbit
    FLASH_SIZE_NIBBLE=6
fi
awk 'BEGIN {printf("%c",'${FLASH_SIZE_NIBBLE}'*16+'${FLASH_SPEED_NIBBLE}');}' </dev/null|dd bs=1 seek=3 count=1 conv=notrunc of="$OUTPUT"

rm "$SPIFFS"
