#!/usr/bin/env python3
'''
A script to list alll available apps, or check the existence of certain app
It will get the list from /home/phablet/.local/share/applications/

Author: Po-Hsu Lin <po-hsu.lin@canonical.com>
'''

import argparse
import json
import subprocess
import sys
import time

delay = 2
parser = argparse.ArgumentParser(description='List / Check Apps')
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('--watch', action='store_true',
                    help='watch current running apps')
group.add_argument('--list', action='store_true',
                    help='list all available click apps')

args = parser.parse_args()

if args.list:
    app_dict = {}

    # Get the click app list first
    data = subprocess.check_output(['adb', 'shell', 'click', 'list', '--manifest']).decode('utf8')
    data = json.loads(data)

    # Get the app executable name
    exec_list = subprocess.check_output(['adb', 'shell', 'ls',
                    '/home/phablet/.local/share/applications', '|', 'sed',
                    's/\.desktop$//']).decode('utf8').split()

    # Collect necessary information into a dictionary
    for app in data:
        if app['title'] not in app_dict:
            # Map the click app list with the app name
            for i, executable in enumerate(exec_list):
                if app['name'] in executable:
                    break
            app_dict[app['title']] = {'ver': [app['version']], 'info': app['maintainer'], 'exec': executable}
        else:
            app_dict[app['title']]['ver'].append(app['version'])


    # Return app titles and version here for QML combobox
    for app in app_dict:
        for ver in app_dict[app]['ver']:
            print('{} ({}), {}'.format(app, ver, app_dict[app]['exec']))

if args.watch:
    try:
        while True:
            print(subprocess.check_output(['adb', 'shell', 'ubuntu-app-list']).decode('utf-8'))
            # Flush the stdout, invoke the onReadyRead event in QML
            sys.stdout.flush()
            time.sleep(delay)
    except KeyboardInterrupt:
        print("Process Terminated by user")
    except Exception as e:
        print("Exception occurred - {}".format(e))
