#!/bin/bash
#
# Script to kill all targeted process on Ubuntu Phone.
#
# This file is part of the Ubuntu Phone pre-loaded app monitoring tool.
#
# Copyright 2016 Canonical Ltd.
# Authors: 
#   Po-Hsu Lin <po-hsu.lin@canonical.com>
#

target=$1
process=`adb shell "ps aux | grep $target" | grep -v "grep" | awk '{print $2}'`
if [ "$process" != '' ]; then
   IFS=' ' eval "array=($process)"
   for pid in "${array[@]}"
   do
       echo "killing $pid"
       adb shell "sudo kill -9" "$pid"
   done
   echo "DONE"
else
   echo "$target is not running"
fi
