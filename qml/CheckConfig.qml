import QtQuick 2.0
import Process 1.0
import "colour.js" as Colour
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2


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
    ColumnLayout {
        anchors.fill: parent
        spacing: units.gu(5)
        Text {
            id: title
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            text: "App Config Check"
            font.pointSize: 16
        }
        Flickable {
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true
            contentHeight: appList.contentHeight
            TextEdit {
                id: log
                text: 'Running Checker...\n'
                font.pointSize: 12
                selectionColor: Colour.palette['Green']
                wrapMode: TextEdit.WordWrap
                cursorPosition: log.text.length
            }
        }
    }
}
