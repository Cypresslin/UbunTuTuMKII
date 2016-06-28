import QtQuick 2.0
import Process 1.0
import "colour.js" as Colour
import QtQuick.Dialogs 1.2
import Ubuntu.Components 1.3

Item {
    Component.onCompleted: {
        console.log('Watcher loaded')
//        cmd_aaLog.start(applicationDirPath + '/utils/adb', ['shell', 'tail', '-f', '/var/log/syslog'])
//        cmd_file_changes.start(applicationDirPath + '/utils/file_watcher.py', ['--changes'])
//        cmd_file_lsof.start(applicationDirPath + '/utils/file_watcher.py', ['--lsof'])
//        cmd_netLog.start(applicationDirPath + '/utils/internet_watcher.py',[])
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
            netLog.text += readAll();
//            console.log(netLog.text)
        }
    }

    Column {
        spacing: units.gu(2)
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 30
        }
        Row {
            id: titleRow
            Text {
                id: title
                text: i18n.tr("Mighty App Watcher")
                font.pointSize: 16
            }
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
        }
        Row {
            id: tcpRow
            spacing: units.gu(1)

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
                    tcpfnText.color = 'green'
                    cmd_tcpPull.start(applicationDirPath + '/utils/adb', ['pull', tcpfnText.text])
                }
            }
            Text {
                id: tcpfnText
                text: ""
            }
        }
        Row {
            id: netTitleRow
            Text {
                text: i18n.tr('Internet Traffic Monitor')
                font.pointSize: 16
            }
        }
        Row {
            id: netRow
            Flickable {
                id: netLogFlickable
                contentHeight: netLog.contentHeight
                clip: true
                height: 150
            }
            TextEdit {
                id: netLog
                text: i18n.tr('internet traffic will be logged here')
                font.pointSize: 10
                selectionColor: Colour.palette['Green']
                wrapMode: TextEdit.WordWrap
                cursorPosition: netLog.text.length
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
