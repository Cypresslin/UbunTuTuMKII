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
import re
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
        # Get all Legacy app desktop file content
        cmd = ['adb', 'shell', 'grep', '', '/usr/share/applications/*.desktop']
        output = subprocess.check_output(cmd).decode('utf8')
        output = output.split('[Desktop Entry]')
        # Exclude app that contains 'OnlyShowIn=Old' and 'NoDisplay=true'
        exclude = ['OnlyShowIn=Old', 'NoDisplay=true']
        # Include app that contains 'X-Ubuntu-Touch=true'
        for item in output:
            if 'X-Ubuntu-Touch=true' in item:
                if all(pattern not in item for pattern in exclude):
                    # Get info for legacy apps and put them into a dictionary
                    regex = '(?P<file_name>.+):'
                    fn = re.search(regex, item).group('file_name')
                    app_exec = fn.replace('/usr/share/applications/', '')
                    app_exec = app_exec.replace('.desktop', '')
                    # Get the name in Name[zh_CN] first, if not available, use the Name instead
                    if 'Name[zh_CN]=' in item:
                        regex = r'Name\[zh_CN\]=(?P<app_name>.+)'
                    else:
                        regex = 'Name=(?P<app_name>.+)'
                    app_name = re.search(regex, item).group('app_name').strip('\r')
                    # Get the version, maintainer information here from dpkg
                    cmd = ['adb', 'shell', 'dpkg', '-s', app_exec, '|', 'grep',
                           '-e', 'Version', '-e', 'Maintainer']
                    info = subprocess.check_output(cmd).decode('utf8').rstrip()
                    contact, ver = info.split('\r\n')
                    contact = contact.split(': ')[1]
                    ver = ver.split(': ')[1].split('+')[0]
                    app_dict[app_name] = {'ver': ver, 'info': contact, 'exec': app_exec}

        # Get the complete info of Click app from manifest
        cmd = ['adb', 'shell', 'click', 'list', '--manifest']
        data = subprocess.check_output(cmd).decode('utf8')
        data = json.loads(data)
        # Get all Click app desktop file content
        cmd = ['adb', 'shell', 'grep', '', '/home/phablet/.local/share/applications/*.desktop']
        output = subprocess.check_output(cmd).decode('utf8')
        output = output.split('[Desktop Entry]')
        # Include app that contains 'X-Ubuntu-Touch=true'
        for item in output:
            if 'X-Ubuntu-Touch=true' in item:
                regex = '(?P<file_name>.+):'
                fn = re.search(regex, item).group('file_name')
                app_exec = fn.replace('/home/phablet/.local/share/applications/', '')
                app_exec = app_exec.replace('.desktop', '')
                # Get the name in Name[zh_CN] first, if not available, use the Name instead
                if 'Name[zh_CN]=' in item:
                    regex = r'Name\[zh_CN\]=(?P<app_name>.+)'
                else:
                    regex = 'Name=(?P<app_name>.+)'
                app_name = re.search(regex, item).group('app_name').strip('\r')
                # Get the version, maintainer information here from manifest
                for entry in data:
                    if entry['name'] in app_exec:
                        app_dict[app_name] = {
                            'ver': entry['version'],
                            'info': entry['maintainer'],
                            'exec': app_exec}
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
