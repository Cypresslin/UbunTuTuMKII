#!/usr/bin/env python3
'''
Script for killing all processes on exit.

This file is part of the Ubuntu Phone pre-loaded app monitoring tool.

Copyright 2016 Canonical Ltd.
Authors:
  Po-Hsu Lin <po-hsu.lin@canonical.com>
'''

from gettext import gettext as _
import common_tools

try:
    cmd = ['dumpsys', 'pactl', 'strace']
    for killme in cmd:
        common_tools.kill(killme)

except KeyboardInterrupt:
    print(_("Process Terminated by user"))
except Exception as e:
    print(_("Exception occurred - {}").format(e))
