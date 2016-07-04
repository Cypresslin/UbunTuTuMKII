import QtQuick 2.0
import Process 1.0
import "colour.js" as Colour
import QtQuick.Dialogs 1.2
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.2


Item {
    Component.onCompleted: {
        console.log('SysLog Watcher loaded')
          cmd_sysLog.start(applicationDirPath + '/utils/syslog_watcher.py', ['--app', appNameLabel.text])
    }
    Process {
        id: cmd_sysLog
        onReadyRead: {
            var string = readAll()
            sysLog.text += string
            console.log(sysLog.text)
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
                text: i18n.tr("AppArmor Syslog Watcher")
                font.pointSize: 16
            }
        }
        Row {
            id: filterRow
            spacing: units.gu(1)
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            Text {
                id: filterLabel
                text: i18n.tr("Watch 'DENIED' events only:")
            }
            Switch {
                id: filterSwitch
                checked: false
                onClicked: toggle()

                function toggle(){
                    if (clearCB.checked){
                        sysLog.text = ""
                    }
                    if (filterSwitch.checked){
                        cmd_filterGo.start(applicationDirPath + '/utils/syslog_watcher.py', ['--denied'])
                    } else {
                        cmd_sysLog.start(applicationDirPath + '/utils/syslog_watcher.py', ['--app', appNameLabel.text])
                    }
                }
            }
            CheckBox {
                id: clearCB
            }
            Label {
                text: i18n.tr("Clear current content")
                anchors.verticalCenter: parent.verticalCenter
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        clearCB.checked = !clearCB.checked
                    }
                }
            }
            Process {
            id: cmd_filterGo
                onReadyRead: {
                    var string = readAll()
                    sysLog.text += string
                }
            }
        }
        Row {
            anchors {
                horizontalCenter: parent.horizontalCenter
             }
            Text {
                text: i18n.tr('Apparmor Syslog Monitor')
                font.pointSize: 16
            }
        }
        Row {
            Flickable {
                contentHeight: sysLog.contentHeight
                width: mainCol.width
                height: 500
                clip: true

                TextEdit {
                    id: sysLog
                    anchors.fill: parent
                    font.pointSize: 10
                    selectionColor: Colour.palette['Green']
                    wrapMode: TextEdit.WordWrap
                    cursorPosition: sysLog.text.length
                }
            }
        }
    }
}
