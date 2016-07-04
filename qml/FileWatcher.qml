import QtQuick 2.0
import Process 1.0
import "colour.js" as Colour
import QtQuick.Dialogs 1.2
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.2


Item {
    Component.onCompleted: {
        console.log('Watcher loaded')
          cmd_file_access.start(applicationDirPath + '/utils/file_watcher.py', ['--access', '--app', appNameLabel.text])
//        cmd_aaLog.start(applicationDirPath + '/utils/adb', ['shell', 'tail', '-f', '/var/log/syslog'])
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


/*    Text {
        id: aaTitle
        anchors {
            top: netLogFlickable.bottom
            horizontalCenter: parent.horizontalCenter
            margins: 30
        }
        text: "Apparmor messages"
        font.pointSize: 16
    }
    Flickable {
        id: aaLogFlickable
        contentHeight: aaLog.contentHeight
        clip: true
        height: 150
        anchors {
            top: aaTitle.bottom
            left: parent.left
            right: parent.right
            margins: 30
        }

        TextEdit {
            id: aaLog
            anchors.fill: parent
            font.pointSize: 10
            selectionColor: Colour.palette['Green']
            wrapMode: TextEdit.WordWrap
            cursorPosition: aaLog.text.length
        }
    }

    Text {
        id: fileTitle
        anchors {
            top: aaLogFlickable.bottom
            horizontalCenter: parent.horizontalCenter
            margins: 30
        }
        text: 'File Access and Modificatios'
        font.pointSize: 16
    }
    Flickable {
        id: fileOpenFlickable
        height: 300
        width: 350
        clip: true
        contentHeight: fileOpenLog.contentHeight
        anchors {
            top: fileTitle.bottom
            left: parent.left
            margins: 30
            bottomMargin: 200
        }
        TextEdit {
            id: fileOpenLog
            anchors.fill: parent
            text: 'Opened files will be logged here'
            font.pointSize: 10
            selectionColor: Colour.palette['Green']
            wrapMode: TextEdit.WordWrap
            cursorPosition: fileOpenLog.text.length
        }
    }
    Flickable {
        height: 300
        width: 350
        clip: true
        contentHeight: fileChangeLog.contentHeight
        anchors {
            top: fileTitle.bottom
            right: parent.right
            margins: 30
            bottomMargin: 200
        }

        TextEdit {
            id: fileChangeLog
            anchors.fill: parent
            text: 'File changes:\n'
            font.pointSize: 10
            selectionColor: Colour.palette['Green']
            wrapMode: TextEdit.WordWrap
            cursorPosition: fileOpenFlickable.text.length
        }
    }
*/
}
