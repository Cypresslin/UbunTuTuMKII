#!/usr/bin/env python3
'''
A script for monitoring file access of certain app.

Author: Po-Hsu Lin <po-hsu.lin@canonical.com>
'''

import argparse
import datetime
import re
import subprocess
import sys

home_dir = '/home/phablet'
parser = argparse.ArgumentParser(description='File monitor')
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('--access', action='store_true',
                    help='Monitor file access with the app')
group.add_argument('--lsof', action='store_true',
                    help='List opened files in {}'.format(home_dir))
group.add_argument('--changes', action='store_true',
                    help='Monitor changes in {}'.format(home_dir))
parser.add_argument('--app', help='Target app', required=True)
args = parser.parse_args()

if args.access:
    try:
        proc_name = args.app
        proc_id = subprocess.check_output(['adb', 'shell', 'ubuntu-app-pid', proc_name]).decode('utf-8').rstrip()
        if proc_id.isnumeric():
            # Supressor list, supress 'stat', 'lstat' and 'getcwd' command
            supressor = ['stat(', 'stat64(', 'getcwd(']
            # Kill the old strace task first, targeted on file watcher process
            process = subprocess.check_output(['adb', 'shell', 'sudo', 'pkill', '-f', 'trace=file'])
            # Track the child processes with -f
            process = subprocess.Popen(['adb', 'shell', 'sudo', 'strace', '-f', '-e', 'trace=file', '-p', proc_id], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            while True:
                output = process.stdout.readline().decode('utf-8').strip()
                if output == '' and process.poll() is not None:
                    break
                else:
                    # Reformat the output, get rid of the [pid #####]
                    output = re.sub('^\[pid\s+\d+\] ', '', output)
                    if not any(mute in output for mute in supressor):
                        # focus on file access in home directory
                        if '/home/phablet/' in output:
                            timestamp='{:%Y%m%d %H:%M:%S}'.format(datetime.datetime.now())
                            print(timestamp, '-', output)
                            sys.stdout.flush()
        else:
            print(proc_name, "is not running")
    except KeyboardInterrupt:
        print("Process Terminated by user")

if args.lsof:
    try:
        process = subprocess.Popen(['adb', 'shell', 'lsof', '-r1', '+D', home_dir], stdout=subprocess.PIPE)
        while True:
            output = process.stdout.readline().decode('utf-8')
            if output == '' and process.poll() is not None:
                break
            else:
                print(output.strip())
    except KeyboardInterrupt:
        print("Process Terminated by user")

if args.changes:
    try:
        process = subprocess.Popen(['adb', 'shell', 'inotifywait', '-rm', home_dir], stdout=subprocess.PIPE)
        while True:
            output = process.stdout.readline().decode('utf-8')
            if output == '' and process.poll() is not None:
                break
            else:
                print(output.strip().replace(home_dir, '~'))
    except KeyboardInterrupt:
        print("Process Terminated by user")

