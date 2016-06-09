#!/usr/bin/env python3
'''Author: Po-Hsu Lin <po-hsu.lin@canonical.com>'''

import subprocess

# Get the app name from the temperorary file
try:
    with open('/tmp/.app_name', 'r') as f:
        app = f.readline()
        print("Checking App: {} ".format(app))

        # The following stuff only need to be checked once
        # Enforced Mode check
        print("Enforce?")
        # Mode check 
        output = subprocess.check_output(['adb', 'shell', 'cat',
                     '/proc/*/attr/current', '|', 'grep', app]).decode('utf-8')
        if ' (enforce)' in output:
            print("YES - {}".format(output))
        else:
            if output == '':
                print("Error: App is not running\n")
            else:
                print("NO - {}".format(output))

        print('Confined?')
        output = subprocess.check_output(['adb', 'shell', 'ps', 'auxZ', '|',
              'grep', '-v', 'unconfined', '|', 'grep', app]).strip().decode('utf8')
        if output:
            print("YES - {}".format(output))
        else:
            print("Error: App is not running, or it's in unconfined mode\n")

        print('\nPolicy Check (/var/lib/apparmor/clicks/{}.json):'.format(app))
        path = '/var/lib/apparmor/clicks/{}.json'.format(app)
        print(subprocess.check_output(['adb', 'shell', 'cat', path]).decode('utf8'))

        print('Final rules:')
        path = '/var/lib/apparmor/profiles/click_{}'.format(app)
        print(subprocess.check_output(['adb', 'shell', 'cat', path]).decode('utf8'))
except:
    print("Error: failed to open /tmp/.app_name, please launch an app first")
