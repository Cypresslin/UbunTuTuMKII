#!/usr/bin/env python3
'''
A script to list all available apps, or watch the behavior of running app
The list was generated from:
1. /usr/share/applications/ for legacy apps
2. ~/.local/share/applications/ for click apps

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

    # Get the exectuable Legacy app list (it's the title as well)
    app_legacy = subprocess.check_output(['adb', 'shell', 'grep', '-l', 'X-Ubuntu-Touch=true', '/usr/share/applications/*.desktop']).decode('utf8')
    app_legacy = app_legacy.replace('/usr/share/applications/', '')
    app_legacy = app_legacy.replace('.desktop', '').split()
    # Exclude key with "OnlyShowIn=Old" and "NoDisplay=true"
    excludes = subprocess.check_output(['adb', 'shell', 'grep', '-l', 'OnlyShowIn=Old', '/usr/share/applications/*']).decode('utf8')
    excludes += subprocess.check_output(['adb', 'shell', 'grep', '-l', 'NoDisplay=true', '/usr/share/applications/*']).decode('utf8')
    excludes = excludes.replace('/usr/share/applications/', '')
    excludes = excludes.replace('.desktop', '').split()
    for exc in excludes:
        if exc in app_legacy:
            app_legacy.remove(exc)
    # Get info for legacy apps and put them into a dictionary
    for app in app_legacy:
        info = subprocess.check_output(['adb', 'shell', 'dpkg', '-s', app, '|', 'grep', '-e', 'Version', '-e', 'Maintainer']).decode('utf8').rstrip()
        contact, ver = info.split('\r\n')
        contact = contact.split(': ')[1]
        ver = ver.split(': ')[1].split('+')[0]
        app_dict[app] = {'ver': ver, 'info': contact, 'exec': app}

    # Get the complete info of Click app from manifest
    data = subprocess.check_output(['adb', 'shell', 'click', 'list', '--manifest']).decode('utf8')
    data = json.loads(data)
    # Get the exectuable Click app list
    app_click = subprocess.check_output(['adb', 'shell', 'grep', '-l', 'X-Ubuntu-Touch=true', '~/.local/share/applications/*.desktop']).decode('utf8')
    app_click = app_click.replace('/home/phablet/.local/share/applications/', '')
    app_click = app_click.replace('.desktop', '').split()
    # Reorganize information and combine with current dictionary
    for item in data:
        if any(item['name'] in app for app in app_click):
            for i, executable in enumerate(app_click):
                if item['name'] in executable:
                    app_dict[item['title']] = {'ver': item['version'], 'info': item['maintainer'], 'exec': executable}
                    break
    # Return app titles and version here for QML combobox
    for app in app_dict:
        print('{} ({}), {}, {}'.format(app, app_dict[app]['ver'], app_dict[app]['exec'], app_dict[app]['info']))

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
