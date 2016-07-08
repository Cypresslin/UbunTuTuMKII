#!/usr/bin/env python3
'''
Script for monitoring local recording events of a targeted app.
Parse the output base on two criteria:
1. 'change' event on 'Source'
2. Check the state of the changed source, highlight if it's 'RUNNING'

This file is part of the Ubuntu Phone pre-loaded app monitoring tool.

Copyright 2016 Canonical Ltd.
Authors:
  Po-Hsu Lin <po-hsu.lin@canonical.com>
'''

import argparse
import datetime
import re
import subprocess
import sys

parser = argparse.ArgumentParser(description='File monitor')
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('--app', help='Target app')
args = parser.parse_args()


try:
     proc_name = args.app
     # Kill the old pactl subscribe task first
     process = subprocess.check_output(['adb', 'shell', 'pkill', '-f', 'pactl subscribe'])
     # Track the audio recording event with pactl
     process = subprocess.Popen(['adb', 'shell', 'pactl', 'subscribe', '|', 'grep', 'source #'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
     while True:
         output = process.stdout.readline().decode('utf-8').strip()
         if output == '' and process.poll() is not None:
             break
         else:
             # Reformat the output
             result = re.search('(\d+$)', output)
             if 'change' in output:
                 num = result.group(0)
                 stat = subprocess.check_output(['adb', 'shell', 'pactl', 'list', 'sources']).decode('utf8')
                 # Focus on the target #
                 stat = re.search('Source #1(?P<status>.*Properties)', stat, re.DOTALL).group('status')
                 if 'RUNNING' in stat:
                     timestamp='{:%m%d %H:%M:%S}'.format(datetime.datetime.now())
                     print("{} <APPNAME>[KEYWORD][{}]:[local recording] {}".format(timestamp, proc_name, 'RUNNING'))
                     sys.stdout.flush()


except KeyboardInterrupt:
    print("Process Terminated by user")
