import QtQuick.Controls 1.4
import QtQuick 2.0
import Process 1.0
import "colour.js" as Colour
import QtQuick.Layouts 1.2

Item {
    Component.onCompleted: {
        console.log('App launcher loaded')
        all_apps.start(applicationDirPath + '/utils/list_app.py', ['--list'])
        cmd_list.start(applicationDirPath + '/utils/list_app.py', ['--watch'])
        cmd_watch.start(applicationDirPath + '/utils/adb', ['shell', 'ubuntu-app-watch'])
    }
    Process {
        id: all_apps
        onReadyRead: {
            var items = readAll().toString().replace(/\n$/, "").split('\n')
            for (var i in items) {
                var item = items[i].split(',')[0].trim()
                var exec = items[i].split(',')[1].trim()
                var info = items[i].split(',')[2].trim()
                console.log(item, '-', exec)
                app_list.append( {text: item, app: exec, maintainer: info} )
            }
            hintText.text = "Ready"
            hintText.color = "lime"
        }
    }
    Process {
        id: cmd_list
        onReadyRead: {
            appList.text = 'Current running apps:\n' + readAll();
        }
    }
    Process {
        id: cmd_watch
        onReadyRead: {
            appStatus.text += readAll();
        }
    }
    ColumnLayout {
        anchors {
            fill: parent
            margins: 40
            topMargin: 30
        }
        spacing: units.gu(5)
        Text {
            id: title
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            text: "App Launcher"
            font.pointSize: 16
        }
        Flickable {
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true
            contentHeight: appList.contentHeight
            TextEdit {
                id: appList
                text: 'Current running apps:\n'
                font.pointSize: 12
                selectionColor: Colour.palette['Green']
            }
        }

        Flickable {
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true
            contentHeight: appStatus.contentHeight
            TextEdit {
                id: appStatus
                anchors.fill: parent
                wrapMode: "WrapAtWordBoundaryOrAnywhere"
                text: 'Status change from ubuntu-app-watch:\n'
                font.pointSize: 12
                selectionColor: Colour.palette['Green']
            }
        }
        Text {
            id: authorLabel
            text: "Maintainers: "
            font.pointSize: 12
        }
        Text {
            id: authorText
            text: "(Please select an App)"
            font.pointSize: 12
            anchors {
                verticalCenter: authorLabel.verticalCenter
                left: authorLabel.right
            }
        }
        Item {
            Layout.fillWidth: true
            height: runButton.height + 40 // pseudo topMargin

            ComboBox {
                id: app_cb
                currentIndex: 0
                width: 250
                anchors {
                    left: parent.left
                    bottom: parent.bottom
                }
                model: ListModel{
                    id: app_list
                    ListElement { text: "Select App..."; app: ''}
                }
                onCurrentIndexChanged: {
                    authorText.text = (app_list.get(currentIndex).maintainer) ? app_list.get(currentIndex).maintainer : "(Please select an App)"
                    console.debug(app_list.get(currentIndex).text + ", " + app_list.get(currentIndex).app)
                }
            }

            Button{
                id: runButton
                anchors {
                    left: app_cb.right
                    bottom: app_cb.bottom
                    leftMargin: 10
                }
                text: "Start!"
                onClicked: {
                    if (app_cb.currentIndex != 0){
                        console.log("Lauching App: " + app_list.get(app_cb.currentIndex).text)
                        launch_cmd.start(applicationDirPath + '/utils/launch_app.sh', [app_list.get(app_cb.currentIndex).app])
                        hintText.text = "App monitoring started"
                        hintText.color = ""
                    } else {
                        console.log("Please select an app to start")
                        hintText.text = "Please select an app to start"
                        hintText.color = "red"
                    }
                }
            }
            Process {
                id: launch_cmd
                onReadyRead:{
                    console.log(readAll())
                }
            }
            Text {
                id: statusText
                anchors {
                    left: runButton.right
                    verticalCenter: app_cb.verticalCenter
                    leftMargin: 5
                }
                text: "Status: "
            }
            Text {
                id: hintText
                anchors {
                    left: statusText.right
                    verticalCenter: app_cb.verticalCenter
                    leftMargin: 5
                }
                text: "Loading app list..."
                color: "red"
            }

        }
    }
}
