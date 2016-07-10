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
        # Supressor list, get rid 127.0.0.1, 127.0.1.1 and error action
        supressor = ['127.0.0.1', '127.0.1.1', ' = -1 E']
        # Kill the old strace task first, targeted on internet watcher process
        process = subprocess.check_output(['adb', 'shell', 'sudo', 'pkill', '-f', 'strace'])
        # focus on connect action
        process = subprocess.Popen(['adb', 'shell', 'sudo', 'strace', '-f', '-e', 'trace=network', '-p', proc_id], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        while True:
            output = process.stdout.readline().decode('utf-8').strip()
            if output == '' and process.poll() is not None:
                break
            else:
                # apply supressor
                if not any(mute in output for mute in supressor):
                    # Extra port and ip
                    output = re.search('sin_port\=htons\((?P<port>\d+)\).*sin_addr=inet_addr\("(?P<ip>.*)"', output)
                    if output:
                        timestamp='{:%m%d %H:%M:%S}'.format(datetime.datetime.now())
                        print("{} <APPNAME>[KEYWORD][{}]:[connect] {}:{}".format(timestamp, proc_name, output.group("ip"),  output.group("port")))
                        sys.stdout.flush()
    else:
        print(proc_name, "is not running")

except KeyboardInterrupt:
    print("Process Terminated by user")

