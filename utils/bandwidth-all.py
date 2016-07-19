#!/usr/bin/env python3
'''
Script for monitoring overall network TX/RX bandwidth.

This file is part of the Ubuntu Phone pre-loaded app monitoring tool.

Copyright 2016 Canonical Ltd.
Authors:
  Po-Hsu Lin <po-hsu.lin@canonical.com>
'''

from gettext import gettext as _
import gettext
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
        output = subprocess.check_output(['adb', 'shell', 'ip', 'link', 'show', 'up', '|', 'sed', '/lo:/d']).decode('utf8')
        devices = re.findall('\d+:\s(?P<interface>\w+)', output)
        # Get the statistic here
        output = subprocess.check_output(['adb', 'shell', 'cat', '/proc/net/dev', '|', 'sed', '-n', '1,2!p']).decode('utf8')
        data = re.finditer('(?P<iface>\w+):\s+(?P<rx>\d+)\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+(?P<tx>\d+)', output)
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
