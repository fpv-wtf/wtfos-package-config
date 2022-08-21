#!/bin/bash

set -e
if [ ! -z $DEBUG ]; then
    set -x
fi

adb connect 192.168.42.5
adb shell mkdir -p /tmp/test
adb push test* /tmp/test
adb push package-config /tmp/test

adb shell "
set -e
export PATH=/sbin:/vendor/bin:/system/sbin:/system/bin:/system/xbin:/opt/bin:/opt/sbin
chmod u+x /tmp/test/tests.sh 
chmod u+x /tmp/test/package-config
opkg install jq
cd /tmp/test
#export DEBUG=true
sh tests.sh" 