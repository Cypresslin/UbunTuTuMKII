#!/usr/bin/env python3
'''
Script for monitoring dumpsys output, it can:
1. Monitor camera access

This file is part of the Ubuntu Phone pre-loaded app monitoring tool.

Copyright 2016 Canonical Ltd.
Authors:
  Po-Hsu Lin <po-hsu.lin@canonical.com>
'''

from gettext import gettext as _
import argparse
import re
import subprocess
import time
import common_tools

cmd = ['adb', 'shell', './dumpsys', 'media.camera', '|', 'grep', '-e', 'Device is', '-e', 'Camera [0-9]']
pattern = 'Camera\s(?P<id>\d+).+\W+Device\sis\s(?P<stat>\w+)'
cameras = {}
parser = argparse.ArgumentParser(description='dumpsys monitor')
parser.add_argument('--proc', help='Target app executable name', required=True)
parser.add_argument('--name', help='Target app human readable name')
args = parser.parse_args()

try:
    proc_name = args.proc
    app_name = args.name if args.name else 'APPNAME'
    proc_id = subprocess.check_output(['adb', 'shell', 'ubuntu-app-pid', proc_name]).decode('utf-8').rstrip()
    if proc_id.isnumeric():
        # Try to kill dumpsys process first
        common_tools.kill('dumpsys')
        # Get the initial state of camera, for change detection later
        prev_result = subprocess.check_output(cmd).decode('utf8')
        stat = re.finditer(pattern, prev_result)
        for item in stat:
            cameras[item.group('id')] = item.group('stat')
        
        while True:
            result = subprocess.check_output(cmd).decode('utf8')
            if prev_result != result:
                prev_result = result
                stat = re.finditer(pattern, result)
                for item in stat:
                    if cameras[item.group('id')] != item.group('stat'):
                        cameras[item.group('id')] = item.group('stat')
                        camera_id = _('Camera #{}').format(item.group('id'))
                        common_tools.printer(app_name, proc_name, 'NO_FUNC', camera_id, item.group('stat'))
            time.sleep(1)
    else:
        print(_("{} is not running").format(proc_name))

except KeyboardInterrupt:
    print(_("Process Terminated by user"))
except Exception as e:
    print(_("Exception occurred - {}").format(e))

