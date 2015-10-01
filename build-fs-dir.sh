#!/bin/sh
HERE=`dirname $0`
HERE=`realpath $HERE`
OUTDIR="$HERE/rootfs"

ENV="$HERE/nodemcu-env"
LUAC="$ENV/nodemcu-firmware/luac.cross"

STATIC=www/static
rm -rf $OUTDIR
mkdir -p $OUTDIR
mkdir -p $OUTDIR/www/static

{
    cd $HERE/www/static
    $HERE/build_index_html.awk  < $HERE/www/index.html.template
} | gzip -n >$OUTDIR/www/static/index.html.gz

for LUA_FILE in \
    init.lua \
    ; do
    cp $HERE/$LUA_FILE $OUTDIR
done

for LUAC_FILE in                \
    main.lua                    \
    pinout.lua                  \
    config.lua                  \
    configure_gpio.lua          \
    configure_wifi.lua          \
    web_ui_routing.lua          \
    web_ui_str_GET.lua          \
    web_ui_str_PUT.lua          \
    web_ui_state_GET.lua        \
    web_ui_state_values_GET.lua \
    web_ui_input_GET.lua        \
    web_ui_output_GET.lua       \
    web_ui_output_idx_GET.lua   \
    web_ui_output_idx_PUT.lua   \
    web_ui_adc_GET.lua          \
    web_ui_config_GET.lua       \
    web_ui_wifi_mode_GET.lua    \
    web_ui_wifi_mode_PUT.lua    \
    web_ui_wifi_config_GET.lua  \
    web_ui_wifi_config_PUT.lua  \
    web_ui_eval_POST.lua        \
    web_ui_static_GET.lua       \
    httpd.lua                   \
    http_util.lua               \
    require_once.lua            \
    ; do
    $LUAC -s -o $OUTDIR/${LUAC_FILE%.lua}.lc $HERE/$LUAC_FILE
done

for STATIC_GZIPPED_FILE in     \
    crossdomain.xml            \
    browserconfig.xml          \
    robots.txt                 \
    ; do
    gzip -n <$HERE/www/static/$STATIC_GZIPPED_FILE >$OUTDIR/www/static/$STATIC_GZIPPED_FILE.gz
done


for STATIC_FILE in     \
    favicon.ico        \
    square70.png       \
    square150.png      \
    wide310.png        \
    square310.png      \
    h5bp-license.txt   \
    ; do
    cp $HERE/www/static/$STATIC_FILE $OUTDIR/www/static/$STATIC_FILE
done
