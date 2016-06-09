#!/bin/sh
#
# Script to setup SSHFS
# Author: Po-Hsu Lin <po-hsu.lin@canonical.com>
#

IP=""
DIR="/tmp/phone"
# enable ssh
adb shell android-gadget-service enable ssh

# Generating ssh key pairs for connection
[ ! -d $HOME/.ssh ] && mkdir $HOME/.ssh
if [ ! -e $HOME/.ssh/id_phone ]; then
    ssh-keygen -C "ubuntu@phone" -t rsa -b 2048 -f $HOME/.ssh/id_phone -N ""
fi

# copy public key
if [ -f $HOME/.ssh/id_phone.pub ]; then
    adb push $HOME/.ssh/id_phone.pub /home/phablet/.ssh/authorized_keys
    adb shell chown -R phablet.phablet /home/phablet/.ssh
    adb shell chmod 700 /home/phablet/.ssh
    adb shell chmod 600 /home/phablet/.ssh/authorized_keys
    IP=`adb shell ifconfig wlan0 | grep "inet addr" | cut -d ":" -f 2 | awk '{print $1}'`
    echo $IP
fi

if [ $IP ]; then
    # Create a tempeorary working directory
    if [ ! -d $DIR ]; then
        mkdir $DIR
    else
        # Make sure it's not mounted before
        echo "Unmounting as root"
        sudo umount $DIR
    fi
    echo "Mounting SSHFS"
    sshfs -oStrictHostKeyChecking=no phablet@$IP:/ $DIR
    
else
    echo "I can't get an IP address from the phone,"
    echo "is it connected to the Internet?"
fi
