#!/bin/bash
#
# Setup the environment for testing.
###########################################################
##  Use with caution, this script can brick your device  ##
###########################################################
#
# Author: Po-Hsu Lin <po-hsu.lin@canonical.com>
#
adb start-server
result=`adb devices | grep "device$"`
if [ $? -eq 0 ]; then
    username=`adb shell whoami`
    echo "User: $username"
    read -rsp "Password: " pass; echo 

    echo 'Re-mount root file-system as writable...'
    adb shell "echo $pass | sudo -S mount -o remount,rw /"
 
    echo 'Setting AppArmor audit level to "all"...'
    adb shell "echo $pass | sudo -S sh -c 'echo -n all > /sys/module/apparmor/parameters/audit'"

    # Allow sudo command, not recommended
    echo 'Adding sudoer setting...'
    adb shell "echo $pass | sudo -S sh -c 'echo -n $username ALL=NOPASSWD: ALL > /etc/sudoers.d/$username'"

    echo "Re-mount root file-system as read-only..."
    adb shell "echo $pass | sudo -S mount -o remount,ro /"

    echo "Pushing tcpdump to the device..."
    adb push tcpdump /home/phablet/

    echo "Job DONE!"    
else
    echo "Oops, please make sure adb works and device connected"
fi
