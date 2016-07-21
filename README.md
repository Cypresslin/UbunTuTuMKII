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

On Ubuntu Linux:

    sudo apt-get install ubuntu-sdk
    cd Process; qmake && make && sudo make install; cd ..
    qmake && make 
    ./UbunTuTu

## Preparation

With your Ubuntu Touch / Phone device connected:

    ./utils/SetupEnv.sh

You will only need to run this once.

Also, you might need to install WireShark to analyze the tcpdump output.

## Credits 

* `utils/convert` is a statically linked ImageMagick version 6.8.9-9 built with `png` delegate 
* `utils/adb` is ADB version 1.0.32 from Android SDK platform tool 
* `utils/nethogs` is nethogs version 0.8.1 built with ARM architecture, please push it to your device in advance.
* `utils/tcpdump` is tcpdump version 4.7.4 built with ARM architecture, please push it to your device in advcane.

## Notes

Before using all of its feature, you will need to allow your device to run command as root, without asking passwords, the SetupEnv.sh script can help you with that.

## License 

Copyright @ 2016 Gavin Lin <<gavin.lin@canonical.com>>

Copyright © 2016 Maciej Kisielewski <<maciej.kisielewski@canonical.com>>

Copyright © 2016 Ping-Hsun (penk) Chen <<penkia@gmail.com>>

Copyright © 2016 Po-Hsu Lin <<po-hsu.lin@canonical.com>>

The source code is distributed under the terms of the GNU GPLv3.
