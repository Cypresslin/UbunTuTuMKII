#!/bin/bash
#
# A script to setup testing environment on your Ubuntu Phone.
###########################################################
##  Use with caution, this script can brick your device  ##
###########################################################
#
# This file is part of the Ubuntu Phone pre-loaded app monitoring tool.
#
# Copyright 2016 Canonical Ltd.
# Authors: 
#   Po-Hsu Lin <po-hsu.lin@canonical.com>
#
adb start-server
result=`adb devices | grep "device$"`
if [ $? -eq 0 ]; then
    # need to get rid of the CarriageReturn here
    username=`adb shell whoami | tr -d '\r'`
    echo "User: $username"
    read -rsp "Password: " pass; echo ""

    echo 'Re-mount root file-system as writable...'
    adb shell "echo $pass | sudo -S mount -o remount,rw /"
 
    echo 'Setting AppArmor audit level to "all"...'
    adb shell "echo $pass | sudo -S sh -c 'echo -n all > /sys/module/apparmor/parameters/audit'"

    # Allow sudo command, not recommended
    echo 'Adding sudoer setting...'
    cmd="$username ALL=NOPASSWD: ALL"
    file="/etc/sudoers.d/$username"
    adb shell "echo $pass | sudo -S sh -c 'echo $cmd > $file'"

    echo "Re-mount root file-system as read-only..."
    adb shell "echo $pass | sudo -S mount -o remount,ro /"

    echo "Pushing tcpdump to the device..."
    adb push tcpdump /home/phablet/

    echo "Job DONE!"    
else
    echo "Oops, please make sure adb works and device connected"
fi
