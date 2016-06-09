#!/bin/bash
#
# App launcher for UbunTuTu App monitor tool
# Author: Po-Hsu Lin <po-hsu.lin@canonical.com>
#

APP=$1
DIR=$2  # This is needed to allow it to launch in parent dir
if [ ! -z $2 ]; then
    DIR=$DIR/utils/
fi

function errorMsg(){
    [ -f /tmp/.app_name ] && rm /tmp/.app_name
    echo "$@"
}

if [ ! -z $APP ]; then
    # Make sure the $APP name is in the app list
    if [ `$DIR./list_app.py --check $APP` == "True" ]; then
        echo "$APP" > /tmp/.app_name
        adb shell nohup ubuntu-app-launch $APP 2&> /dev/null
        echo "$APP launched"
    else
        errorMsg "Error: App $APP not found"
    fi
else
    errorMsg "Error: No app name was given"
fi
