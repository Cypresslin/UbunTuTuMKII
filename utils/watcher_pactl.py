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
import kill_proc

parser = argparse.ArgumentParser(description='Sensitive event monitor with pactl')
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('--app', help='Target app')
args = parser.parse_args()


try:
    proc_name = args.app
    # It's no necessary to get PID here, but still check it
    proc_id = subprocess.check_output(['adb', 'shell', 'ubuntu-app-pid', proc_name]).decode('utf-8').rstrip()
    if proc_id.isnumeric():
        status = ['RUNNING', 'IDLE']
        # Kill the old pactl subscribe task first
        kill_proc.kill('pactl')
        # Track the audio recording event with pactl
        process = subprocess.Popen(['adb', 'shell', 'pactl', 'subscribe', '|', 'grep', 'source #'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        while True:
            output = process.stdout.readline().decode('utf-8').strip()
            if output == '' and process.poll() is not None:
                break
            else:
                if 'change' in output:
                    num = re.search('(\d+$)', output).group(0)
                    detail = subprocess.check_output(['adb', 'shell', 'pactl', 'list', 'sources']).decode('utf8')
                    # Reformat the output, truncate the output from source ~ properties
                    pattern = 'Source #{}(?P<status>.*Properties)'.format(num)
                    detail = re.search(pattern, detail, re.DOTALL).group('status')
                    for stat in status:
                        if stat in detail:
                            timestamp='{:%m%d %H:%M:%S}'.format(datetime.datetime.now())
                            print("{TIME} <{APP}>[{KEYWORD}][{PROC}]:[{FUNC}] {ACT} {PARM}".format(
                                TIME = timestamp,
                                APP = "APPNAME",
                                KEYWORD = "KEYWORD",
                                PROC = proc_name,
                                FUNC = 'source',
                                ACT = 'local record',
                                PARM = stat))
                            sys.stdout.flush()
    else:
        print(proc_name, "is not running")

except KeyboardInterrupt:
    print("Process Terminated by user")
except Exception as e:
    print("Exception occurred - {}".format(e))
