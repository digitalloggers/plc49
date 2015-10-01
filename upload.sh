#!/bin/sh
HERE=`dirname $0`
HERE=`realpath $HERE`
ENV="$HERE/nodemcu-env";
ROOTFS="$HERE/rootfs";
UPDATE="$1";shift
CACHE="$HERE/rootfs-cache"
if ! [ -d "${CACHE}" ]; then
    rm -rf "${CACHE}"
    mkdir -p "${CACHE}"
fi
UPLOADER=${ENV}/nodemcu-uploader/nodemcu-uploader.py
UPLOADER_OPTS="--fail_on_error"
UPLOADER_ARGS=""
if [ -n "${ESP8266_PORT}" ]; then
    UPLOADER_OPTS="${UPLOADER_OPTS} --port ${ESP8266_PORT}"
fi
if [ -n "${ESP8266_BAUD}" ]; then
    UPLOADER_OPTS="${UPLOADER_OPTS} --baud ${ESP8266_BAUD}"
fi
cd ${ROOTFS}
for F in `find . -type f`; do
    CACHE_FILE="${CACHE}"/$F
    if [ $UPDATE -eq 0 ] || ! [ -f "${CACHE_FILE}" ] || ! cmp "${F}" "${CACHE_FILE}"; then
        UPLOADER_ARGS="${UPLOADER_ARGS} ${F}:${F#./}"
        mkdir -p `dirname "${CACHE_FILE}"`
        rm -f "${CACHE_FILE}"
    fi
done
if [ $UPDATE -eq 0 ]; then
    "${UPLOADER}" ${UPLOADER_OPTS} file format
    while ! "${UPLOADER}" ${UPLOADER_OPTS} upload -r ${UPLOADER_ARGS}; do
        echo "Upload failure detected, restarting..."
    done
else
    if [ -z "${UPLOADER_ARGS}" ]; then
        echo "No changes since last upload"
    else
        while ! "${UPLOADER}" ${UPLOADER_OPTS} upload ${UPLOADER_ARGS}; do
            echo "Upload failure detected, restarting..."
        done
    fi
fi
for F in `find . -type f`; do
    CACHE_FILE="${CACHE}"/$F
    mkdir -p `dirname "${CACHE_FILE}"`
    cp "${F}" "${CACHE_FILE}"
done
