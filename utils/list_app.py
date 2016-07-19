#!/usr/bin/env python3
'''
Script for listing all installed apps, or list the running apps.
The installed app list was generated from:
1. /usr/share/applications/ for legacy apps
2. ~/.local/share/applications/ for click apps

This file is part of the Ubuntu Phone pre-loaded app monitoring tool.

Copyright 2016 Canonical Ltd.
Authors:
  Po-Hsu Lin <po-hsu.lin@canonical.com>
'''

from gettext import gettext as _
import argparse
import json
import subprocess
import sys
import time
import common_tools

delay = 2
parser = argparse.ArgumentParser(description='List / Check Apps')
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('--watch', action='store_true',
                   help='watch current running apps')
group.add_argument('--list', action='store_true',
                   help='list all available click apps')

args = parser.parse_args()

try:
    if args.list:
        app_dict = {}
        # Get the exectuable Legacy app list (it's the title as well)
        cmd = ['adb', 'shell', 'grep', '-l', 'X-Ubuntu-Touch=true',
               '/usr/share/applications/*.desktop']
        fn_legacy = subprocess.check_output(cmd).decode('utf8')
        fn_legacy = fn_legacy.split()
        # Exclude file that with "OnlyShowIn=Old" and "NoDisplay=true" key
        cmd = ['adb', 'shell', 'grep', '-l', 'OnlyShowIn=Old',
               '/usr/share/applications/*']
        excludes = subprocess.check_output(cmd).decode('utf8')
        cmd = ['adb', 'shell', 'grep', '-l', 'NoDisplay=true',
               '/usr/share/applications/*']
        excludes += subprocess.check_output(cmd).decode('utf8')
        excludes = excludes.split()
        for exc in excludes:
            if exc in fn_legacy:
                fn_legacy.remove(exc)
        # Get info for legacy apps and put them into a dictionary
        for fn in fn_legacy:
            # Reformat the executable name
            app_exec = fn.replace('/usr/share/applications/', '')
            app_exec = app_exec.replace('.desktop', '')
            # Get the name in Name[zh_CN] first, if not available, use the Name instead
            cmd = ['adb', 'shell', 'grep', r'^Name\[zh_CN\]=', fn]
            app_name = subprocess.check_output(cmd).decode('utf8').rstrip()
            if app_name:
                app = app_name.split('=')[1]
            else:
                cmd = ['adb', 'shell', 'grep', '^Name=', fn]
                app_name = subprocess.check_output(cmd).decode('utf8').rstrip()
                app = app_name.split('=')[1]
            cmd = ['adb', 'shell', 'dpkg', '-s', app_exec, '|', 'grep',
                   '-e', 'Version', '-e', 'Maintainer']
            info = subprocess.check_output(cmd).decode('utf8').rstrip()
            contact, ver = info.split('\r\n')
            contact = contact.split(': ')[1]
            ver = ver.split(': ')[1].split('+')[0]
            app_dict[app] = {'ver': ver, 'info': contact, 'exec': app_exec}

        # Get the complete info of Click app from manifest
        cmd = ['adb', 'shell', 'click', 'list', '--manifest']
        data = subprocess.check_output(cmd).decode('utf8')
        data = json.loads(data)
        # Get the exectuable Click app list
        cmd = ['adb', 'shell', 'grep', '-l', 'X-Ubuntu-Touch=true',
               '/home/phablet/.local/share/applications/*.desktop']
        fn_click = subprocess.check_output(cmd).decode('utf8')
        fn_click = fn_click.split()

        # Put app name into a dictionary for later query
        app_click = {}
        for fn in fn_click:
            # Reformat the executable name
            app_exec = fn.replace('/home/phablet/.local/share/applications/', '')
            app_exec = app_exec.replace('.desktop', '')
            # Get the name in Name[zh_CN] first, if not available, use the Name instead
            cmd = ['adb', 'shell', 'grep', r'^Name\[zh_CN\]=', fn]
            app_name = subprocess.check_output(cmd).decode('utf8').rstrip()
            if app_name:
                app = app_name.split('=')[1]
            else:
                cmd = ['adb', 'shell', 'grep', '^Name=', fn]
                app_name = subprocess.check_output(cmd).decode('utf8').rstrip()
                app = app_name.split('=')[1]
            app_click[app_exec] = app
        # Reorganize information and combine with current dictionary
        for item in data:
            if any(item['name'] in app for app in app_click):
                for i, executable in enumerate(app_click):
                    if item['name'] in executable:
                        app_dict[app_click[executable]] = {
                            'ver': item['version'],
                            'info': item['maintainer'],
                            'exec': executable}
                        break

        # Return app titles and version here for QML combobox
        for app in app_dict:
            print('{}, ({}), {}, {}'.format(
                app,
                app_dict[app]['ver'],
                app_dict[app]['exec'],
                app_dict[app]['info']))

    if args.watch:
        while True:
            print(subprocess.check_output(['adb', 'shell', 'ubuntu-app-list']).decode('utf-8'))
            # Flush the stdout, invoke the onReadyRead event in QML
            sys.stdout.flush()
            time.sleep(delay)

except KeyboardInterrupt:
    print(_("Process Terminated by user"))
except Exception as e:
    print(_("Exception occurred - {}").format(e))
