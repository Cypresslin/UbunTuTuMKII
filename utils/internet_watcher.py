#!/usr/bin/env python3
'''
Script for monitoring network connections of a targeted app.

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

parser = argparse.ArgumentParser(description='Network connection monitor')
parser.add_argument('--app', help='Target app', required=True)
args = parser.parse_args()

try:
    proc_name = args.app
    proc_id = subprocess.check_output(['adb', 'shell', 'ubuntu-app-pid', proc_name]).decode('utf-8').rstrip()
    if proc_id.isnumeric():
        # Supressor list, get rid of 127.0.0.1 and 127.0.1.1 as well
        supressor = ['bind(', 'recv(', 'send(', 'socket(', 'getsockopt(', 'recvmsg(', 'setsockopt(', '127.0.0.1', '127.0.1.1']
        # Kill the old strace task first, targeted on internet watcher process
        process = subprocess.check_output(['adb', 'shell', 'sudo', 'pkill', '-f', 'strace'])
        process = subprocess.Popen(['adb', 'shell', 'sudo', 'strace', '-f', '-e', 'trace=network', '-p', proc_id], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        while True:
            output = process.stdout.readline().decode('utf-8').strip()
            if output == '' and process.poll() is not None:
                break
            else:
                # Reformat the output, get rid of the [pid #####]
                output = re.sub('^\[pid\s+\d+\] ', '', output)
                if not any(mute in output for mute in supressor):
                    # focus on address
                    if 'addr' in output:
                        timestamp='{:%Y%m%d %H:%M:%S}'.format(datetime.datetime.now())
                        print(timestamp, '-', output)
                        sys.stdout.flush()
    else:
        print(proc_name, "is not running")

except KeyboardInterrupt:
    print("Process Terminated by user")

