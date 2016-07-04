import QtQuick 2.0
import Process 1.0
import "colour.js" as Colour
import QtQuick.Dialogs 1.2
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.2


Item {
    Component.onCompleted: {
        console.log('Net Watcher loaded')
          cmd_bandwidth_all.start(applicationDirPath + '/utils/bandwidth-all.py', [''])
          cmd_netLog.start(applicationDirPath + '/utils/internet_watcher.py',['--app', appNameLabel.text])
    }
    Process {
        id: cmd_bandwidth_all
        onReadyRead: {
            var string = readAll()
            bandwidthAll.text = string
        }
    }
    Process {
        id: cmd_netLog
        onReadyRead: {
            var string = readAll()
            netLog.text += string
            console.log(netLog.text)
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
                text: i18n.tr("Internet Watcher")
                font.pointSize: 16
            }
        }
        Row {
            id: tcpRow
            spacing: units.gu(1)
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            Text {
                id: tcpdumpLabel
                text: i18n.tr("TCP dump:")
            }
            Switch {
                anchors {
                    verticalCenter: tcpdumpLabel.verticalCenter
                }
                id: tcpdumpSwitch
                checked: false
                onClicked: toggle()

                function timestamp() {
                    var locale =  Qt.locale()
                    var currentTime = new Date()
                    return currentTime.toLocaleString(locale, "yyyyMMdd-hh-mm-ss")
                }

                function toggle(){
                    if (tcpdumpSwitch.checked){
                        var filename = timestamp() + '.pcap' 
                        tcpfnText.text = filename
                        tcpfnText.color = 'black'
                        cmd_tcpGo.start(applicationDirPath + '/utils/adb', ['shell', 'sudo', './tcpdump', '-n', '-w', filename])
                    } else {
                        cmd_tcpStop.start(applicationDirPath + '/utils/adb', ['shell', 'sudo', 'pkill', '-f', 'tcpdump'])
                    }
                }
            }
            Process {
            id: cmd_tcpGo
                onReadyRead: {
                    console.log(readAll())
                }
            }
            Process {
            id: cmd_tcpStop
                onReadyRead: {
                    console.log(readAll())
                }
            }
            Process {
            id: cmd_tcpPull
                onReadyRead: {
                    console.log(readAll())
                }
            }
            Button {
                id: tcpcpButton
                text: i18n.tr("Copy file")
                anchors {
                    verticalCenter: tcpdumpLabel.verticalCenter
                }
                onClicked: {
                    if (tcpfnText.text == ""){
                        messageDialog.icon = StandardIcon.Critical
                        messageDialog.text = "Please start TCP dump first"
                    } else {
                        messageDialog.icon = StandardIcon.Information
                        messageDialog.text = "File copied to:" + applicationDirPath + '/'
                        cmd_tcpPull.start(applicationDirPath + '/utils/adb', ['pull', tcpfnText.text])
                    }
                    messageDialog.visible = true;
                }
            }
            Text {
                id: tcpfnText
                text: ""
            }
            MessageDialog {
                id: messageDialog
                title: "File copy"
            }
        }
        Row {
            anchors {
                horizontalCenter: parent.horizontalCenter
             }
            Text {
                text: i18n.tr('Overall Bandwidth Monitor')
                font.pointSize: 16
            }
        }
        Row {
            anchors {
                horizontalCenter: parent.horizontalCenter
             }
            TextEdit {
                id: bandwidthAll
                font.pointSize: 10
                selectionColor: Colour.palette['Green']
                wrapMode: TextEdit.WordWrap
                cursorPosition: bandwidthAll.text.length
            }
        }
        Row {
            anchors {
                horizontalCenter: parent.horizontalCenter
             }
            Text {
                text: i18n.tr('Connection Monitor')
                font.pointSize: 16
            }
        }
        Row {
            Flickable {
                contentHeight: netLog.contentHeight
                width: mainCol.width
                height: 500
                clip: true

                TextEdit {
                    id: netLog
                    anchors.fill: parent
                    font.pointSize: 10
                    selectionColor: Colour.palette['Green']
                    wrapMode: TextEdit.WordWrap
                    cursorPosition: netLog.text.length
                }
            }
        }
    }
}
