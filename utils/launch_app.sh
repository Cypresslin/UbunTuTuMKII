#!/bin/bash
#
# A script to launch apps on Ubuntu Phone.
#
# This file is part of the Ubuntu Phone pre-loaded app monitoring tool.
#
# Copyright 2016 Canonical Ltd.
# Authors: 
#   Po-Hsu Lin <po-hsu.lin@canonical.com>
#
APP=$1

function errorMsg(){
    [ -f /tmp/.app_name ] && rm /tmp/.app_name
    echo "$@"
}

if [ ! -z $APP ]; then
    echo "$APP" > /tmp/.app_name
    adb shell nohup ubuntu-app-launch $APP > /dev/null
    echo "$APP launched"
else
    errorMsg "Error: No app name was given"
fi
