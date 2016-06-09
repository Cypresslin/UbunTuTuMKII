# UbunTuTuMKII - App monitor tool

UbunTuTuMKII, a variant form Penk's UbunTuTu, is a prototyping graphical tool for monitoring app activities.

![screenshot](https://raw.githubusercontent.com/Cypresslin/UbunTuTuMKII/master/images/screenshot.png)

## Features

* Get system image version 
* Launch and monitor app life cycle
* Check app settings
* Reset Trust store permissions 
* Monitor App file access activities
* Monitor App network activities
* Monitor AppArmor messages

## Build 

On Linux:

    cd Process; qmake && make && sudo make install; cd ..
    qmake && make 
    ./UbunTuTu.app

## Credits 

* `utils/convert` is a statically linked ImageMagick version 6.8.9-9 built with `png` delegate 
* `utils/adb` is ADB version 1.0.32 from Android SDK platform tool 
* `utils/nethogs` is nethogs version 0.8.1 built with ARM architecture, please push it to your device in advance.

## Notes

The name of the executed app will be stored in /tmp/.app_name.
Whenever you need to call certain app name, just read that file

## License 

Copyright © 2016 Ping-Hsun (penk) Chen <<penkia@gmail.com>>
Copyright © 2016 Po-Hsu Lin <<po-hsu.lin@canonical.com>>

The source code is, unless otherwise specified, distributed under the terms of the MIT License.
