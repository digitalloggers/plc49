#!/bin/sh
unset MAKEFLAGS
export MAKEFLAGS
unset MAKELEVEL
export MAKELEVEL
HERE=`dirname $0`
HERE=`realpath $HERE`
cd $HERE/nodemcu-env
./build.sh