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
import os
import re
import subprocess
import sys
import time
import common_tools

delay = 2
fn_list = '/tmp/app_list'
parser = argparse.ArgumentParser(description='List / Check Apps')
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('--watch', action='store_true',
                   help='watch current running apps')
group.add_argument('--list', action='store_true',
                   help='list all available click apps')
parser.add_argument('--save', action='store_true',
                    help='Save output for --list to /tmp/app_list')
args = parser.parse_args()


try:
    if args.list:
        app_dict = {}
        # Remove /tmp/app_list with subprocess, to mute file not found error
        if args.save and os.path.isfile(fn_list):
            os.remove(fn_list)
        # Get all Legacy app desktop file content
        cmd = ['adb', 'shell', 'grep', '', '/usr/share/applications/*.desktop']
        output = subprocess.check_output(cmd).decode('utf8')
        output = output.split('[Desktop Entry]')
        # Exclude app that contains 'OnlyShowIn=Old' and 'NoDisplay=true'
        exclude = ['OnlyShowIn=Old', 'NoDisplay=true']
        tmp_dict = {}
        for item in output:
            # Include app that contains 'X-Ubuntu-Touch=true'
            if 'X-Ubuntu-Touch=true' in item:
                if all(pattern not in item for pattern in exclude):
                    # Get info for legacy apps and put them into a dictionary
                    regex = '(?P<file_name>.+):'
                    fn = re.search(regex, item).group('file_name')
                    app_exec = fn.replace('/usr/share/applications/', '')
                    app_exec = app_exec.replace('.desktop', '')
                    # Get the name in Name[zh_CN] first, if not available, use 'Name' instead
                    if 'Name[zh_CN]=' in item:
                        regex = r'Name\[zh_CN\]=(?P<app_name>.+)'
                    else:
                        regex = 'Name=(?P<app_name>.+)'
                    app_name = re.search(regex, item).group('app_name').strip('\r')
                    tmp_dict[app_exec] = app_name
                    # Get the keyword in English, if not available, use 'Name' instead
                    if 'Keywords=' in item:
                        regex = r'Keywords=(?P<app_keyword>\w+)'
                    else:
                        regex = 'Name=(?P<app_keyword>.+)'
                    app_keyword = re.search(regex, item).group('app_keyword').strip('\r')
                    app_dict[app_name] = {'keyword': app_keyword,
                                          'exec': app_exec}
        # Get the version, maintainer information here from dpkg, not doing this in the loop
        # to avoid extensive adb calls
        cmd = ['adb', 'shell', 'dpkg', '-s'] + list(tmp_dict)
        cmd += ['|', 'grep', '-e', 'Package', '-e', 'Version', '-e', 'Maintainer']
        info = subprocess.check_output(cmd).decode('utf8').rstrip()
        info = info.split('\r\n')
        for item in tmp_dict:
            # Assume the version and maintainer info will be printed in the desired order
            idx = info.index('Package: ' + item)
            contact = info[idx + 1].split(': ')[1]
            ver = info[idx + 2].split(': ')[1].split('+')[0]
            # Keys are the pretty name of the app, assign the new keys instead of new key sets
            app_dict[tmp_dict[item]]['ver'] = ver
            app_dict[tmp_dict[item]]['info'] = contact

        # Get the complete info of Click app from manifest
        cmd = ['adb', 'shell', 'click', 'list', '--manifest']
        data = subprocess.check_output(cmd).decode('utf8')
        data = json.loads(data)
        # Get all Click app desktop file content
        cmd = ['adb', 'shell', 'grep', '',
               '/home/phablet/.local/share/applications/*.desktop']
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
                # Get the keyword in English, if not available, use the Name instead
                if 'Keywords=' in item:
                    regex = r'Keywords=(?P<app_keyword>\w+)'
                else:
                    regex = 'Name=(?P<app_keyword>.+)'
                app_keyword = re.search(regex, item).group('app_keyword').strip('\r')
                # Get the version, maintainer information here from manifest
                for entry in data:
                    if entry['name'] in app_exec:
                        app_dict[app_name] = {
                            'keyword': app_keyword,
                            'ver': entry['version'],
                            'info': entry['maintainer'],
                            'exec': app_exec}
                        break

        # Return app titles and version here for QML combobox
        output = ''
        for app in sorted(app_dict):
            output += ('{}, {}, ({}), {}, {}\n'.format(
                app,
                app_dict[app]['keyword'],
                app_dict[app]['ver'],
                app_dict[app]['exec'],
                app_dict[app]['info']))
        output = output.rstrip()
        if args.save:
            with open(fn_list, 'w') as f:
                f.write(output)
        else:
            print(output)
        # Print is needed here to allow the onReadyRead in qml to continue
        print('Done')
        sys.stdout.flush()

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
