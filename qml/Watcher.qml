import QtQuick 2.0
import Process 1.0
import "colour.js" as Colour
import QtQuick.Dialogs 1.2

Item {
    Component.onCompleted: {
        console.log('Watcher loaded')
        cmd_aaLog.start(applicationDirPath + '/utils/adb', ['shell', 'tail', '-f', '/var/log/syslog'])
        cmd_file_changes.start(applicationDirPath + '/utils/file_watcher.py', ['--changes'])
        cmd_file_lsof.start(applicationDirPath + '/utils/file_watcher.py', ['--lsof'])
        cmd_netLog.start(applicationDirPath + '/utils/internet_watcher.py',[])
    }
    Process {
        id: cmd_aaLog
        onReadyRead: {
            aaLog.text += readAll();
            console.log(aaLog.text)
        }
    }
    Process {
        id: cmd_file_changes
        onReadyRead: {
            fileChangeLog.text += readAll();
            console.log(fileChangeLog.text)
        }
    }
    Process {
        id: cmd_file_lsof
        onReadyRead: {
            fileOpenLog.text = readAll();
            console.log(fileOpenLog.text)
        }
    }
    Process {
        id: cmd_netLog
        onReadyRead: {
            netLog.text = readAll();
            console.log(netLog.text)
        }
    }


    Text {
        id: title
        anchors {
            top: parent.top
            topMargin: 30
            horizontalCenter: parent.horizontalCenter
        }
        text: "Mighty App Watcher"
        font.pointSize: 16
    }

    Text {
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

    Text {
        id: netTitle
        anchors {
            top: title.bottom
            horizontalCenter: parent.horizontalCenter
            margins: 30
        }
        text: 'Internet Traffic Monitor'
        font.pointSize: 16
    }
    Flickable {
        id: netLogFlickable
        contentHeight: netLog.contentHeight
        clip: true
        height: 150
        anchors {
            top: netTitle.bottom
            left: parent.left
            right: parent.right
            margins: 30
        }
        TextEdit {
            id: netLog
            text: 'internet traffic will be logged here'
            font.pointSize: 10
            selectionColor: Colour.palette['Green']
            wrapMode: TextEdit.WordWrap
            cursorPosition: fileOpenLog.text.length
        }
    }
}
