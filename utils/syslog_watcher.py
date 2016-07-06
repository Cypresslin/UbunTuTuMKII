#!/usr/bin/env python3
'''
Script for monitoring AppArmor message in syslog of a targeted app.

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

parser = argparse.ArgumentParser(description='Syslog monitor')
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('--denied', action='store_true',
                   help='Monitor DENIED pattern in syslog')
group.add_argument('--app', help='Targeted app')
args = parser.parse_args()

try:
    if args.denied:
        proc_name = 'DENIED'
    else:
        proc_name = args.app
    proc_id = subprocess.check_output(['adb', 'shell', 'ubuntu-app-pid', proc_name]).decode('utf-8').rstrip()
    if proc_id.isnumeric() or args.denied:
        # Try to kill tailf process first
        output = subprocess.check_output(['adb', 'shell', 'sudo', 'pkill', '-f', 'tailf'])
        process = subprocess.Popen(['adb', 'shell', 'tailf', '/var/log/syslog', '|', 'grep', proc_name], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        while True:
            output = process.stdout.readline().decode('utf-8').strip()
            if output == '' and process.poll() is not None:
                break
            else:
                # Reformat the output, remove everything till apparmor: 
                # Jul  4 07:44:41 ubuntu-phablet kernel: [49335.660041]  [2:     QQmlThread: 6411] [c2] type=1400 audit(1467618281.378:140077): apparmor="DENIED" operation="open" profile="webbrowser-app" name="/run/shm/lttng-ust-wait-6" pid=6411 comm="QQmlThread" requested_mask="r" denied_mask="r" fsuid=32011 ouid=32011
                output = re.sub('.*apparmor=', 'apparmor:', output)
                output = re.sub('operation=', 'action:', output)
                # remove fsuid/ouid
                output = re.sub('fsuid=\d+\souid=\d+', '', output)
                # remove pid
                output = re.sub('pid=\d+\s', '', output)

                # output here
                timestamp='{:%Y%m%d %H:%M:%S}'.format(datetime.datetime.now())
                print(timestamp, '-', output)
                sys.stdout.flush()
    else:
        print(proc_name, "is not running")

except KeyboardInterrupt:
    print("Process Terminated by user")
