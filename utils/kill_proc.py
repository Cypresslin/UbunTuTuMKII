'''
Script to kill all targeted process on Ubuntu Phone.
Using subprocess but not psutil, as we will need root privilege. 

This file is part of the Ubuntu Phone pre-loaded app monitoring tool.

Copyright 2016 Canonical Ltd.
Authors:
  Po-Hsu Lin <po-hsu.lin@canonical.com>
'''

import subprocess

def kill(proc):
    output=subprocess.check_output(['adb', 'shell', 'ps' ,'aux', '|', 'grep', proc, '|', 'grep', '-v', 'grep']).decode('utf8')
    if output:
        output = output.rstrip().split('\n')
        for line in output:
            pid = line.split()[1]
            process = subprocess.check_output(['adb', 'shell', 'sudo', 'kill', '-9', pid])
