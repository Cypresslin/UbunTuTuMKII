#!/usr/bin/env python3
'''
Script for checking basic config for a targeted app.

This file is part of the Ubuntu Phone pre-loaded app monitoring tool.

Copyright 2016 Canonical Ltd.
Authors:
  Po-Hsu Lin <po-hsu.lin@canonical.com>
'''

import argparse
import json
import subprocess

parser = argparse.ArgumentParser(description='Check basic config for an App')
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('--check-mode', action='store_true',
                   help='Check the AppArmor profile mode')
group.add_argument('--check-process', action='store_true',
                   help='Check if the process is confined by an AppArmor profile')
group.add_argument('--check-policy', action='store_true',
                   help='Check the AppArmor policy for the app')
group.add_argument('--copy-rules', action='store_true',
                   help='Copy the AppArmor Final Rules for the app')
parser.add_argument('--app', help='Target app', required=True)
args = parser.parse_args()

# Get the app name from the temperorary file
try:
    proc_name = args.app

    if args.check_mode:
        output = subprocess.check_output(['adb', 'shell', 'cat',
                     '/proc/*/attr/current', '|', 'grep', proc_name]).decode('utf-8')
        if ' (enforce)' in output:
            print("Enforcement Mode")
        else:
            if output == '':
                print("Error: App is not running")
            else:
                print("Complain Mode")
    elif args.check_process:
        output = subprocess.check_output(['adb', 'shell', 'ps', 'auxZ', '|',
              'grep', '-v', 'unconfined', '|', 'grep', proc_name]).strip().decode('utf8')
        if output:
            print("YES")
        else:
            print("Error: App is not running, or it's unconfined")
    elif args.check_policy:
        path = '/var/lib/apparmor/clicks/{}.json'.format(proc_name)
        output = subprocess.check_output(['adb', 'shell', 'cat', path]).decode('utf8')
        output = json.loads(output)
        for key in output:
            print(key, ':',output[key])
    elif args.copy_rules:
        path = '/var/lib/apparmor/profiles/click_{}'.format(proc_name)
        output = subprocess.check_output(['adb', 'pull', path]).decode('utf8')
        print("Done: file copied")
except:
    print("Error: please select an app first")
