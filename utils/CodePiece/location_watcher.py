#!/usr/bin/env python3
'''
Script for monitoring location events.

This file is part of the Ubuntu Phone pre-loaded app monitoring tool.

Copyright 2016 Canonical Ltd.
Authors:
  Po-Hsu Lin <po-hsu.lin@canonical.com>
'''

import argparse
import datetime
import re
import subprocess
import sys

parser = argparse.ArgumentParser(description='location event monitor')
parser.add_argument('--proc', help='Target app executable name', required=True)
parser.add_argument('--name', help='Target app human readable name')
args = parser.parse_args()

try:
    proc_name = args.proc
    app_name = args.name if args.name else 'APPNAME'
    proc_id = subprocess.check_output(['adb', 'shell', 'ubuntu-app-pid', proc_name]).decode('utf-8').rstrip()
    if proc_id.isnumeric():
        # Try to kill strace process first
        output = subprocess.check_output(['adb', 'shell', 'sudo', 'pkill', '-f', 'strace'])
        process = subprocess.Popen(['adb', 'shell', 'sudo', 'strace', '-f', '-e', 'trace=sendmsg,recvmsg', '-s', '400' , '-p', proc_id], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        while True:
            output = process.stdout.readline().decode('utf-8').strip()
            if output == '' and process.poll() is not None:
                break
            else:
                # Print only when it's location.Service related
                if "location.Service" in output:
                    # Reformat the output, extract events and remove human non-readable parts:
                    # Remove [pid ####]
                    output = re.sub('^\[pid\s+\d+\] ', '', output)
                    # Remove msg_* and MSG_*
                    output = re.sub('msg_\w+(\(\d\))*=*\w+', '', output, re.S ,re.I)
                    # Rename and Relocate com.ubuntu.location.Service
                    output = re.sub('com.ubuntu.location.Service', '', output)
                    output = 'LocationService: ' + output
                    # Filter message by parsing meaningful strings
                    words = re.findall('[a-z][a-z]{2,}', output, re.I)
                    output = ' '.join(words)
                    
                    # output here
                    timestamp='{:%Y%m%d %H:%M:%S}'.format(datetime.datetime.now())
                    print(timestamp, '-', output)
                    sys.stdout.flush()
    else:
        print(proc_name, "is not running")

except KeyboardInterrupt:
    print("Process Terminated by user")
except Exception as e:
    print("Exception occurred - {}".format(e))
