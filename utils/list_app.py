#!/usr/bin/env python3
'''
A script to list alll available apps, or check the existence of certain app
It will get the list from /home/phablet/.local/share/applications/
Author: Po-Hsu Lin <po-hsu.lin@canonical.com>
'''

import argparse
import subprocess

parser = argparse.ArgumentParser(description='List / Check Apps')
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('--check', 
                    help='Check if the following app is in the list')
group.add_argument('--list', action='store_true',
                    help='list all available apps')

args = parser.parse_args()


# Get all available apps first
apps = subprocess.check_output(['adb', 'shell', 'ls',
    '/home/phablet/.local/share/applications', '|', 'sed',
     's/\.desktop$//']).decode('utf8').split()

# print the list here
if args.list:
    for app in apps:
        print(app)

# Check if it's in the list here
if args.check:
    if args.check in apps:
        print('True')
    else:
        print('False')
