#!/bin/sh
HERE=`dirname $0`
HERE=`realpath $HERE`
ENV="$HERE/nodemcu-env"
IMAGE="$HERE/plc49.bin"
ESPTOOL=${ENV}/esp-open-sdk/esptool/esptool.py
ESPTOOL_OPTS=""
if [ -n "${ESP8266_PORT}" ]; then
    ESPTOOL_OPTS="${ESPTOOL_OPTS} --port ${ESP8266_PORT}"
fi
if [ -n "${ESP8266_BAUD}" ]; then
    ESPTOOL_OPTS="${ESPTOOL_OPTS} --baud ${ESP8266_BAUD}"
fi
"${ESPTOOL}" ${ESPTOOL_OPTS} write_flash --flash_verbatim 0 "${IMAGE}"
