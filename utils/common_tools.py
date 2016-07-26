'''
Python module for common functions.

This file is part of the Ubuntu Phone pre-loaded app monitoring tool.

Copyright 2016 Canonical Ltd.
Authors:
  Po-Hsu Lin <po-hsu.lin@canonical.com>
'''
import datetime
import gettext
import os
import subprocess
import sys
import printer_dict as i18n

locale_path = os.getcwd()
if locale_path.split('/')[-1] == 'utils':
    locale_path += '/../share/locale'
else:
    locale_path += '/share/locale'
gettext.bindtextdomain('ubuntutu', locale_path)
gettext.textdomain('ubuntutu')



def kill(proc):
    '''Function to kill all targeted process on Ubuntu Phone.
       Using subprocess but not psutil, as we will need root privilege.
    '''
    cmd = ['adb', 'shell', 'ps', 'aux', '|', 'grep', proc, '|',
           'grep', '-v', 'grep']
    output = subprocess.check_output(cmd).decode('utf8')
    if output:
        output = output.rstrip().split('\n')
        for line in output:
            pid = line.split()[1]
            subprocess.check_output(['adb', 'shell', 'sudo', 'kill', '-9', pid])


def printer(app_name, app_keyword, proc_name, func_name, act_name, item):
    '''
    Function to print required format output.
    '''
    timestamp = '{:%m%d %H:%M:%S}'.format(datetime.datetime.now())
    print("{TIME} <{APP}>[{KEYWORD}][{PROC}]:[{FUNC}] {ACT} {PARM}".format(
        TIME=timestamp,
        APP=app_name,
        KEYWORD=app_keyword,
        PROC=proc_name,
        FUNC=func_name,
        ACT=i18n.table[act_name] if act_name in i18n.table else act_name,
        PARM=item))
    sys.stdout.flush()
