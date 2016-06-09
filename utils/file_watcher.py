#!/usr/bin/env python3
'''
Author: Po-Hsu Lin <po-hsu.lin@canonical.com>
'''

import argparse
import subprocess

home_dir = '/home/phablet'
parser = argparse.ArgumentParser(description='File monitor')
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('--lsof', action='store_true',
                    help='List opened files in {}'.format(home_dir))
group.add_argument('--changes', action='store_true',
                    help='Monitor changes in {}'.format(home_dir))
args = parser.parse_args()

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

