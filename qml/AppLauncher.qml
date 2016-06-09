import QtQuick 2.0
import Process 1.0
import "colour.js" as Colour
import QtQuick.Dialogs 1.2
import Ubuntu.Components 0.1

Item {
    Component.onCompleted: {
        console.log('App launcher loaded')
        cmd_list.start(applicationDirPath + '/utils/adb', ['shell', 'ubuntu-app-list'])
        cmd_watch.start(applicationDirPath + '/utils/adb', ['shell', 'ubuntu-app-watch'])
    }
    Process {
        id: cmd_list
        onReadyRead: {
            appList.text +=  readAll();
        }
    }
    Process {
        id: cmd_watch
        onReadyRead: {
            appStatus.text += readAll();
        }
    }

    Text {
        id: title
        anchors {
            top: parent.top
            topMargin: 30
            horizontalCenter: parent.horizontalCenter
        }
        text: "Apps status:"
        font.pointSize: 16
    }

    TextEdit {
        id: appList
        anchors {
            top: title.bottom
            right: parent.rigt
            left: parent.left
            margins: 40
        }
        text: 'Current running apps:\n'
        font.pointSize: 12
        selectionColor: Colour.palette['Green']
    }

    TextEdit {
        id: appStatus
        anchors {
            top: appList.bottom
            right: parent.rigt 
            left: parent.left
            bottom: sendButton.top
            margins: 40
        }
        text: 'Status change from ubuntu-app-watch:\n'
        font.pointSize: 12
        selectionColor: Colour.palette['Green']
    }


    Button{
            id: sendButton
            anchors {
                right: clear.right
                bottom: parent.bottom
                margins: 30
            }
            text: "Launch!"
            onClicked: {
                console.log("Lauching App: " + textInput.text)
                launch_cmd.start(applicationDirPath + '/utils/launch_app.sh', [textInput.text, applicationDirPath])
            }
    }

    Process {
        id: launch_cmd
        onReadyRead:{
            console.log(readAll())
        }
    }

    Text {
        id: typeSomething
        anchors {
            left: parent.left
            right: sendButton.left
            bottom: parent.bottom
            margins: 40
        }
        text: "App name"
        color: "gray"
        font.italic: true
        font.pointSize: 14
    }

    TextInput {
        id: textInput
        anchors {
            left: parent.left;
            right: sendButton.left;
            bottom: parent.bottom
            margins: 40}
        focus: true;
        selectByMouse: true
        font.pointSize: 14
    }

    FocusScope {
        id: focusScope
        width: 250; height: 28

        property string text: textInput.text
        signal clear

        onClear: {
            textInput.text=""
        }
    }

    Image {
        id: clear
        anchors {
            right: parent.right;
            rightMargin: 8;
            verticalCenter: parent.verticalCenter }

        MouseArea {
            // allow area to grow beyond image size
            // easier to hit the area on high DPI devices
            anchors.centerIn: parent
            height:focusScope.height
            width: focusScope.height
            onClicked: {
                //toogle focus to be able to jump out of input method composer
                focusScope.focus = false;
                textInput.text = '';
                focusScope.focus = true;
            }
        }
    }

    states: State {
        name: "hasText"; when: (textInput.text != '' || textInput.inputMethodComposing)
        PropertyChanges { target: typeSomething; opacity: 0 }
        PropertyChanges { target: clear; opacity: 1 }
    }

    transitions: [
        Transition {
            from: ""; to: "hasText"
            NumberAnimation { exclude: typeSomething; properties: "opacity" }
        },
        Transition {
            from: "hasText"; to: ""
            NumberAnimation { properties: "opacity" }
        }
    ]

}
