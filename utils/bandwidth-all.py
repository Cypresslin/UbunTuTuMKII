#!/usr/bin/env python3
'''
Script for monitoring overall network TX/RX bandwidth.

This file is part of the Ubuntu Phone pre-loaded app monitoring tool.

Copyright 2016 Canonical Ltd.
Authors:
  Po-Hsu Lin <po-hsu.lin@canonical.com>
'''

from gettext import gettext as _
import re
import subprocess
import sys
import time
import common_tools


delay = 2
template = "{0:15}|{1:15}|{2:15}"
try:
    while True:
        # Get the up-and-running device interfaces, mute lo here
        cmd = ['adb', 'shell', 'ip', 'link', 'show', 'up', '|', 'sed', '/lo:/d']
        output = subprocess.check_output(cmd).decode('utf8')
        devices = re.findall(r'\d+:\s(?P<interface>\w+)', output)
        # Get the statistic here
        cmd = ['adb', 'shell', 'cat', '/proc/net/dev', '|', 'sed', '-n', '1,2!p']
        output = subprocess.check_output(cmd).decode('utf8')
        pattern = r'(?P<iface>\w+):\s+(?P<rx>\d+)\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+(?P<tx>\d+)'
        data = re.finditer(pattern, output)
        print(template.format(_("Interface"), _("RX Bytes"), _("TX Bytes")))
        for item in data:
            if item.group('iface') in devices:
                print(template.format(item.group('iface'), item.group('rx'), item.group('tx')))
        print(_("Update every {} seconds").format(delay))
        sys.stdout.flush()
        time.sleep(delay)
except KeyboardInterrupt:
    print(_('Process Terminated by user'))
except Exception as e:
    print(_("Exception occurred - {}").format(e))
