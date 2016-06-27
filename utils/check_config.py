#!/usr/bin/env python3
'''
A script to check basic config for an app
It will get the app name from /tmp/.app_name

Author: Po-Hsu Lin <po-hsu.lin@canonical.com>
'''


import argparse
import json
import subprocess

parser = argparse.ArgumentParser(description='Check basic config for an App')
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('--app-name', action='store_true',
                   help='Print the target App name')
group.add_argument('--check-mode', action='store_true',
                   help='Check the AppArmor profile mode')
group.add_argument('--check-process', action='store_true',
                   help='Check if the process is confined by an AppArmor profile')
group.add_argument('--check-policy', action='store_true',
                   help='Check the AppArmor policy for the app')
group.add_argument('--check-rules', action='store_true',
                   help='Check the Finale Rules for the app')

args = parser.parse_args()

# Get the app name from the temperorary file
try:
    with open('/tmp/.app_name', 'r') as f:
        app = f.readline()

    if args.app_name:
        print(app)
    if args.check_mode:
        output = subprocess.check_output(['adb', 'shell', 'cat',
                     '/proc/*/attr/current', '|', 'grep', app]).decode('utf-8')
        if ' (enforce)' in output:
            print("Enforcement Mode")
        else:
            if output == '':
                print("Error: App is not running")
            else:
                print("Complain Mode")
    elif args.check_process:
        output = subprocess.check_output(['adb', 'shell', 'ps', 'auxZ', '|',
              'grep', '-v', 'unconfined', '|', 'grep', app]).strip().decode('utf8')
        if output:
            print("YES")
        else:
            print("Error: App is not running, or it's unconfined")
    elif args.check_policy:
        path = '/var/lib/apparmor/clicks/{}.json'.format(app)
        output = subprocess.check_output(['adb', 'shell', 'cat', path]).decode('utf8')
        output = json.loads(output)
        for key in output:
            print(key, ':',output[key])
    elif args.check_rules:
        path = '/var/lib/apparmor/profiles/click_{}'.format(app)
        output = subprocess.check_output(['adb', 'shell', 'cat', path]).decode('utf8')
        print(output)
except:
    print("Error: failed to open /tmp/.app_name, please launch an app first")
