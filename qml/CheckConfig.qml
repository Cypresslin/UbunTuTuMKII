import QtQuick 2.0
import Process 1.0
import "colour.js" as Colour
import QtQuick.Dialogs 1.2

Item {
    Component.onCompleted: {
        console.log('Check Config')
        shell.start(applicationDirPath + '/utils/check_config.py', [])
    }
    Process {
        id: shell
        onReadyRead: {
            log.text += readAll();
            console.log(log.text)
        }
    }

    Text {
        id: title
        anchors {
            top: parent.top
            topMargin: 30
            horizontalCenter: parent.horizontalCenter
        }
        text: "App Config Check"
        font.pointSize: 16
    }

    TextEdit {
        id: log
        anchors {
            top: title.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 40
        }
        text: 'Running Checker...\n'
        font.pointSize: 12
        selectionColor: Colour.palette['Green']
        wrapMode: TextEdit.WordWrap
        cursorPosition: log.text.length
    }
}
