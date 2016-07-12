/*
 * This file is part of the Ubuntu Phone pre-loaded app monitoring tool.
 *
 * Copyright 2016 Canonical Ltd.
 * Authors:
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
        console.log('Watcher loaded')
          cmd_file_access.start(applicationDirPath + '/utils/file_watcher.py', ['--access', '--proc', appProcLabel.text, '--name', appNameLabel.text])
    }
    Process {
        id: cmd_file_access
        onReadyRead: {
            var string = readAll()
            fileAccLog.text += string
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
                text: i18n.tr("File Access Watcher")
                font.pointSize: 16
            }
        }
        Row {
            id: fileAccTitleRow
            anchors {
                horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: 'File Access'
                font.pointSize: 16
            }
        }
        Row {
            id: fileAccRow
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            Flickable {
                contentHeight: fileAccLog.contentHeight
                width: mainCol.width
                height: 400
                clip: true

                TextEdit {
                    id: fileAccLog
                    anchors.fill: parent
                    font.pointSize: 10
                    selectionColor: Colour.palette['Green']
                    wrapMode: TextEdit.WordWrap
                    cursorPosition: fileAccLog.text.length
                }
            }
        }
    }
}
