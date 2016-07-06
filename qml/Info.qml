/*
 * This file is part of the Ubuntu Phone pre-loaded app monitoring tool.
 *
 * Copyright 2016 Canonical Ltd.
 * Authors:
 *   Maciej Kisielewski <maciej.kisielewski@canonical.com>
 *   Ping-Hsun (penk) Chen <penkia@gmail.com>
 *   Po-Hsu Lin <po-hsu.lin@canonical.com>
 */
import QtQuick 2.0
import Process 1.0
import "colour.js" as Colour
import Ubuntu.Components 0.1

Item {
    Component.onCompleted: {
        console.log('Info loaded')
        sic.start(applicationDirPath + '/utils/adb', ['shell', 'system-image-cli', '-i'])
    }
    Process {
        id: sic
        onReadyRead: {
            console.log('onReadyRead');
            systemImageCli.text += readAll();
            console.log(systemImageCli.text)
        }
    }

    Text {
        anchors {
            top: parent.top
            topMargin: 30
            horizontalCenter: parent.horizontalCenter
        }
        text: i18n.tr("System Information")
        font.pointSize: 16
    }

    TextEdit {
        id: systemImageCli
        anchors.centerIn: parent 
        font.pointSize: 16
        selectionColor: Colour.palette['Green']
    }
}
