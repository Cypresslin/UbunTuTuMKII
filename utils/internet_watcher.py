#!/usr/bin/env python3
'''
Author: Po-Hsu Lin <po-hsu.lin@canonical.com>
'''
import subprocess

home_dir = '/home/phablet'
try:
    process = subprocess.Popen(['adb', 'shell', 'sudo', './nethogs', 'wlan0'], stdout=subprocess.PIPE)
    while True:
        output = process.stdout.readline().decode('utf-8')
        if output == '' and process.poll() is not None:
            break
        else:
            print(output.strip())
except KeyboardInterrupt:
    print("Process Terminated by user")

