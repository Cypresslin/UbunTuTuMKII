#!/usr/bin/env python3
'''
Script for monitoring overall network TX/RX bandwidth.

Author: Po-Hsu Lin <po-hsu.lin@canonical.com>
'''


import re
import subprocess
import sys
import time

delay = 2
template = "{0:15}|{1:15}|{2:15}"
while True:
    # Mute lo here
    output = subprocess.check_output(['adb', 'shell', 'cat', '/proc/net/dev', '|', 'sed', '-n', '1,2!p', '|', 'sed', '/lo:/d']).decode('utf8')
    data = re.finditer('(?P<iface>\w+):\s+(?P<rx>\d+)\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+(?P<tx>\d+)', output)
    print(template.format("Interface", "RX Bytes", "TX Bytes"))
    for item in data:
        print(template.format(item.group('iface'), item.group('rx'), item.group('tx')))
    sys.stdout.flush()
    time.sleep(delay)
