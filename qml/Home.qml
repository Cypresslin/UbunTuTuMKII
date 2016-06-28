import QtQuick 2.0
import Process 1.0
import "colour.js" as Colour
import Ubuntu.Components 0.1

Item {
    Component.onCompleted: {
        console.log('Home loaded')
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
