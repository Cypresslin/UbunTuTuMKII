#!/bin/bash
#
# App launcher for UbunTuTu App monitor tool
# Author: Po-Hsu Lin <po-hsu.lin@canonical.com>
#

APP=$1

function errorMsg(){
    [ -f /tmp/.app_name ] && rm /tmp/.app_name
    echo "$@"
}

if [ ! -z $APP ]; then
    echo "$APP" > /tmp/.app_name
    adb shell nohup ubuntu-app-launch $APP 2&> /dev/null
    echo "$APP launched"
else
    errorMsg "Error: No app name was given"
fi
