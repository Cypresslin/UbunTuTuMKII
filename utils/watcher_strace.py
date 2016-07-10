#!/usr/bin/env python3
'''
Script for monitoring sensitive events with strace command on of a targeted app.
This is for:
1. Contact
2. Calendar
3. Location
4. MobileNetwork switch
5. Internet connections
6. File access to personal data

This file is part of the Ubuntu Phone pre-loaded app monitoring tool.

Copyright 2016 Canonical Ltd.
Authors:
  Po-Hsu Lin <po-hsu.lin@canonical.com>
'''

import argparse
import datetime
import os
import re
import subprocess
import sys

def printer(proc_name, func_name, act_name, item):
    timestamp='{:%m%d %H:%M:%S}'.format(datetime.datetime.now())
    print("{TIME} <{APP}>[{KEYWORD}][{PROC}]:[{FUNC}] {ACT} {PARM}".format(
          TIME = timestamp,
          APP = "APPNAME",
          KEYWORD = "KEYWORD",
          PROC = proc_name,
          FUNC = func_name,
          ACT = act_name,
          PARM = item))
    sys.stdout.flush()


parser = argparse.ArgumentParser(description='Sensitive event monitor with strace')
parser.add_argument('--app', help='Target app', required=True)
args = parser.parse_args()

try:
    proc_name = args.app
    proc_id = subprocess.check_output(['adb', 'shell', 'ubuntu-app-pid', proc_name]).decode('utf-8').rstrip()
    if proc_id.isnumeric():
        # Supressor list, get rid of error action, and local ip for connect event
        supressor = [' = -1 E', '127.0.0.1', '127.0.1.1']
        # Desired events
        events = {'AddressBook': ('updateContacts', 'removeContacts', 'createContact', 'contactsDetails'),
                  'Calendar': ('CreateObjects', 'RemoveObjects', 'ModifyObjects', 'GetObjectList'),
                  'location': ('StartPositionUpdates', 'StopPositionUpdates'),
                  'connectivity': ('MobileDataEnabled', 'DataRoamingEnabled')}
        # Target directories, assume user name will be phablet
        home = '/home/phablet/'
        dirs = ('Documents', 'Music', 'Pictures', 'Videos')
        # Kill the old strace task first, targeted on internet watcher process
        process = subprocess.check_output(['adb', 'shell', 'sudo', 'pkill', '-f', 'strace'])
        # focus on sendmsg action
        process = subprocess.Popen(['adb', 'shell', 'sudo', 'strace', '-f', '-s', '4096','-e', 'trace=sendmsg,connect,open,unlink', '-p', proc_id], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        while True:
            output = process.stdout.readline().decode('utf-8').strip()
            if output == '' and process.poll() is not None:
                break
            # apply supressor
            elif not any(mute in output for mute in supressor):
                # For internet watcher
                if 'connect' in output:
                    # Extract port and ip
                    addr = re.search('sin_port\=htons\((?P<port>\d+)\).*sin_addr=inet_addr\("(?P<ip>.*)"', output)
                    if addr:
                        printer(proc_name, 'connect', addr.group("ip") + ':', addr.group("port"))
                # For other events
                elif 'sendmsg' in output:
                    # Search for the corresponding event
                    for item in events:
                        if item in output:
                            # Search for corresponding actions
                            for action in events[item]:
                                if action in output:
                                    printer(proc_name, 'sendmsg', action, item)
                                    break
                # For file access, put it here to ignore sendmsg
                elif home in output :
                    for item in dirs:
                        if item in output:
                            # Get function name here
                            func = re.search('\s(\w+)\(', output).group(1)
                            # Get the filename here
                            pattern = '{}(.+)\"'.format(item)
                            path = re.search(pattern, output).group(0)
                            # Remove the trailing '/', so we can get the name if it's a dir
                            path = path.rstrip('/')
                            root, filename = os.path.split(path)
                            printer(proc_name, func, item, filename)
                            break
    else:
        print(proc_name, "is not running")

except KeyboardInterrupt:
    print("Process Terminated by user")
except Exception as e:
    print("Exception occurred - {}".format(e))
