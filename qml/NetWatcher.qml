/*
 * This file is part of the Ubuntu Phone pre-loaded app monitoring tool.
 *
 * Copyright 2016 Canonical Ltd.
 * Authors:
 *   Maciej Kisielewski <maciej.kisielewski@canonical.com>
 *   Po-Hsu Lin <po-hsu.lin@canonical.com>
 */

import QtQuick 2.0
import Process 1.0
import "colour.js" as Colour
import QtQuick.Dialogs 1.2
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.2


Item {
    Component.onCompleted: {
        console.log('Net Watcher loaded')
          cmd_bandwidth_all.start(applicationDirPath + '/utils/bandwidth-all.py', [''])
    }
    Process {
        id: cmd_bandwidth_all
        onReadyRead: {
            var string = readAll()
            bandwidthAll.text = string
        }
    }

    Column {
        id: mainCol
        anchors { 
            fill: parent
            margins: 30
            
            horizontalCenter: parent.horizontalCenter
        }
        spacing: units.gu(2)
        Row {
            id: titleRow
            spacing: units.gu(2)
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            Text {
                id: title
                text: i18n.tr("Internet Watcher")
                font.pointSize: 16
            }
        }
        Row {
            anchors {
                horizontalCenter: parent.horizontalCenter
             }
            Text {
                text: i18n.tr('Overall Bandwidth Monitor')
                font.pointSize: 16
            }
        }
        Row {
            anchors {
                horizontalCenter: parent.horizontalCenter
             }
            TextEdit {
                id: bandwidthAll
                font.pointSize: 10
                selectionColor: Colour.palette['Green']
                wrapMode: TextEdit.WordWrap
                cursorPosition: bandwidthAll.text.length
            }
        }
    }
}
