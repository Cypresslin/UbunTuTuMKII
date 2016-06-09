import QtQuick 2.0
import Process 1.0
import "colour.js" as Colour

Item {
    Component.onCompleted: {
        console.log('TrustStore loaded')
        shell.start(applicationDirPath + '/utils/reset_trust_store.sh', ['UbuntuLocationService', 'CameraService', 'PulseAudio'])

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
        text: "Reset Trust-Store Permission"
        font.pointSize: 16
    }

    TextEdit {
        id: log
        anchors {
            top: title.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 30
        }
        text: 'Resetting the trust-store permission of "UbuntuLocationService", "CameraService", "PulseAudio":\n'
        font.pointSize: 12
        selectionColor: Colour.palette['Green']
        wrapMode: TextEdit.WordWrap
        cursorPosition: log.text.length
    }
}
