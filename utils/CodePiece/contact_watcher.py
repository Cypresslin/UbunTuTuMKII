#!/usr/bin/env python3
'''
Script for monitoring contact activities of a targeted app.

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

parser = argparse.ArgumentParser(description='Contact activites monitor')
parser.add_argument('--proc', help='Target app executable name', required=True)
parser.add_argument('--name', help='Target app human readable name')
args = parser.parse_args()

try:
    proc_name = args.proc
    app_name = args.name if args.name else 'APPNAME'
    proc_id = subprocess.check_output(['adb', 'shell', 'ubuntu-app-pid', proc_name]).decode('utf-8').rstrip()
    if proc_id.isnumeric():
        # Supressor list, get rid of error action
        supressor = [' = -1 E']
        # Desired events
        events = ['updateContacts', 'removeContacts', 'createContact', 'contactsDetails']
        # Kill the old strace task first, targeted on internet watcher process
        process = subprocess.check_output(['adb', 'shell', 'sudo', 'pkill', '-f', 'strace'])
        # focus on connect action
        process = subprocess.Popen(['adb', 'shell', 'sudo', 'strace', '-f', '-s', '4096','-e', 'trace=sendmsg', '-p', proc_id], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        while True:
            output = process.stdout.readline().decode('utf-8').strip()
            if output == '' and process.poll() is not None:
                break
            else:
                # apply supressor
                if not any(mute in output for mute in supressor) and 'AddressBook' in output:
                    # Extra desired events
                    for event in events:
                        if event in output:
                            timestamp='{:%m%d %H:%M:%S}'.format(datetime.datetime.now())
                            print("{} <{}>[KEYWORD][{}]:[{}] {}".format(timestamp, app_name, proc_name, event, event))
                            sys.stdout.flush()
    else:
        print(proc_name, "is not running")

except KeyboardInterrupt:
    print("Process Terminated by user")
except Exception as e:
    print("Exception occurred - {}".format(e))
