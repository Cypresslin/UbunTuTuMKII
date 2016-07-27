#!/usr/bin/env python3
'''
Script for monitoring sensitive events with strace command on of a targeted app.
This is for:
1. Contact
2. Calendar
3. Location
4. MobileNetwork switch
5. Internet connections
6. File access to personal data
7. Call history
8. Music file being set to play

This file is part of the Ubuntu Phone pre-loaded app monitoring tool.

Copyright 2016 Canonical Ltd.
Authors:
  Po-Hsu Lin <po-hsu.lin@canonical.com>
'''

from gettext import gettext as _
import argparse
import os
import re
import subprocess
import common_tools

# Flag for connection events
connected = False
parser = argparse.ArgumentParser(description='Sensitive event monitor with strace')
parser.add_argument('--proc', help='Target app executable name', required=True)
parser.add_argument('--name', help='Target app human readable name')
parser.add_argument('--keyword', help='Target app keyword')
args = parser.parse_args()

try:
    proc_name = args.proc
    app_name = args.name if args.name else 'APPNAME'
    app_keyword = args.keyword if args.keyword else 'KEYWORD'
    cmd = ['adb', 'shell', 'ubuntu-app-pid', proc_name]
    proc_id = subprocess.check_output(cmd).decode('utf-8').rstrip()
    if proc_id.isnumeric():
        # Supressor list, get rid of error action, and local ip for connect event
        supressor = [' = -1 E', '127.0.0.1', '127.0.1.1']
        # Desired events
        events = {'AddressBook': ('updateContacts', 'removeContacts', 'createContact', 'contactsDetails'),
                  'Calendar': ('CreateObjects', 'RemoveObjects', 'ModifyObjects', 'GetObjectList'),
                  'location': ('StartPositionUpdates', 'StopPositionUpdates'),
                  'connectivity': ('MobileDataEnabled', 'DataRoamingEnabled'),
                  'HistoryService': ('QueryEvents', 'RemoveEvents')}
        # Target directories, assume user name will be phablet
        home = '/home/phablet/'
        dirs = ('Documents', 'Music', 'Pictures', 'Videos')
        # Kill the old strace task first, targeted on internet watcher process
        common_tools.kill('strace')
        # focus on sendmsg action
        cmd = ['adb', 'shell', 'sudo', 'strace', '-f', '-s', '4096', '-e',
               'trace=sendmsg,connect,open,unlink,write', '-p', proc_id]
        process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        while True:
            output = process.stdout.readline().decode('utf-8').strip()
            if output == '' and process.poll() is not None:
                break
            # apply supressor
            elif not any(mute in output for mute in supressor):
                # Filter out all write event without setMedia()
                if '] write(' in output:
                    if 'setMedia()' not in output:
                        continue
                # For internet watcher
                if not connected and '] connect(' in output:
                    # Extract port and ip
                    pattern = r'sin_port\=htons\((?P<port>\d+)\).*sin_addr=inet_addr\("(?P<ip>.*)"'
                    addr = re.search(pattern, output)
                    if addr:
                        common_tools.printer(
                            app_name,
                            app_keyword,
                            proc_name,
                            'connect',
                            addr.group("ip") + ':',
                            addr.group("port"))
                        connected = True
                # For file import events
                # (it's also a sendmsg event, put it here as we need to parse the output)
                elif 'CreateImportFromPeer' in output:
                    pattern = r',\s\{'+ '\"(.+){}'.format(proc_name)
                    source = re.search(pattern, output).group(1)
                    # Filter message by parsing meaningful strings
                    # This is a process name, it contains numbers and symbols
                    words = re.findall('[a-z][a-z.1-9_]{2,}', source, re.I)
                    source = ''.join(words)
                    pattern = '{}(.+)\"'.format(proc_name)
                    filetype = re.search(pattern, output).group(1)
                    # Filter message by parsing meaningful strings
                    words = re.findall('[a-z][a-z]{2,}', filetype, re.I)
                    filetype = ''.join(words)
                    common_tools.printer(
                        app_name,
                        app_keyword,
                        proc_name,
                        _('CreateImportFromPeer'),
                        filetype,
                        _('From: ') + source)
                # For file export events
                # (it's also a sendmsg event, put it here as we need to parse the output)
                elif 'dbus.Transfer' in output and 'Charge' in output:
                    for item in output.split('\\0'):
                        if 'file' in item:
                            filename = item
                            common_tools.printer(
                                app_name,
                                app_keyword,
                                proc_name,
                                _('Exporting file: '),
                                filename.replace('file://', ''),
                                '')
                            break
                # For other events
                elif 'sendmsg' in output:
                    # Search for the corresponding event
                    for item in events:
                        if item in output:
                            # Search for corresponding actions
                            for action in events[item]:
                                if action in output:
                                    common_tools.printer(
                                        app_name,
                                        app_keyword,
                                        proc_name,
                                        action,
                                        item,
                                        '')
                                    break
                # For file access, put it here to ignore sendmsg
                # For music file being set to play
                elif 'setMedia()' in output:
                    for item in output.split('\\"'):
                        if 'file' in item:
                            filename = item
                            common_tools.printer(
                                app_name,
                                app_keyword,
                                proc_name,
                                _('Set to play: '),
                                filename.replace('file://', ''),
                                '')
                            break
                # For other personal data access events
                elif home in output:
                    for item in dirs:
                        if item in output:
                            # Get function name here
                            func = re.search(r'\s(\w+)\(', output).group(1)
                            # Get the filename here
                            pattern = '{}(?P<path>.+)\"'.format(item)
                            path = re.search(pattern, output).group('path')
                            # Remove the trailing '/', so we can get the name if it's a dir
                            path = path.rstrip('/')
                            root, filename = os.path.split(path)
                            # Get the file access action for "open" here
                            pattern = r'",\s(?P<action>\w+)'
                            act = re.search(pattern, output)
                            if act:
                                act = act.group('action')
                            else:
                                act = func
                            common_tools.printer(
                                app_name,
                                app_keyword,
                                proc_name,
                                act,
                                '~/{}/'.format(item),
                                filename)
                            break
    else:
        print(_("{} is not running").format(proc_name))

except KeyboardInterrupt:
    print(_("Process Terminated by user"))
except Exception as e:
    print(_("Exception occurred - {}").format(e))
