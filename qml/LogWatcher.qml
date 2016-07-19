/*
 * This file is part of the Ubuntu Phone pre-loaded app monitoring tool.
 *
 * Copyright 2016 Canonical Ltd.
 * Authors:
 *   Po-Hsu Lin <po-hsu.lin@canonical.com>
 */
import QtQuick 2.0
import Process 1.0
import QtQuick.Dialogs 1.2
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.2

Item {
    Component.onCompleted: {
        console.log('SysLog Watcher loaded')
          cmd_dumpsys.start(applicationDirPath + '/utils/watcher_dumpsys.py', ['--proc', appProcLabel.text, '--name', appNameLabel.text, '--keyword', appKeyLabel.text])
          cmd_strace.start(applicationDirPath + '/utils/watcher_strace.py', ['--proc', appProcLabel.text, '--name', appNameLabel.text, '--keyword', appKeyLabel.text])
          cmd_pactl.start(applicationDirPath + '/utils/watcher_pactl.py', ['--proc', appProcLabel.text, '--name', appNameLabel.text, '--keyword', appKeyLabel.text])
    }
    Process {
        id: cmd_dumpsys
        onReadyRead: {
            var string = readAll()
            sysLog.text += string
        }
    }
    Process {
        id: cmd_strace
        onReadyRead: {
            var string = readAll()
            sysLog.text += string
        }
    }
    Process {
        id: cmd_pactl
        onReadyRead: {
            var string = readAll()
            sysLog.text += string
        }
    }
    MessageDialog {
        id: messageDialog
    }
    Column {
        id: mainCol
        spacing: units.gu(2)
        anchors { 
            fill: parent
            margins: 30
            horizontalCenter: parent.horizontalCenter
        }

        Row {
            id: netRow
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            spacing: units.gu(2)
            Text {
                id: tcpdumpLabel
                text: i18n.tr("Internet Content Logger (TCP dump)")
                font.pointSize: 14
            }
            Switch {
                anchors.verticalCenter: tcpdumpLabel.verticalCenter
                id: tcpdumpSwitch
                checked: false
                onClicked: toggle()

                function timestamp() {
                    var locale =  Qt.locale()
                    var currentTime = new Date()
                    return currentTime.toLocaleString(locale, "MMdd-hh-mm-ss")
                }

                function toggle(){
                    if (tcpdumpSwitch.checked){
                        if (appProcLabel.text == "PROC NAME"){
                            messageDialog.icon = StandardIcon.Critical
                            messageDialog.text = i18n.tr("APP is not running")
                            messageDialog.visible = true
                            tcpdumpSwitch.checked = false
                        } else {
                            var filename = 'tcpdump-' + timestamp() + '.pcap'
                            tcpfnText.text = filename
                            cmd_tcpGo.start(applicationDirPath + '/utils/adb', ['shell', 'sudo', './tcpdump', '-n', '-w', filename])
                        }
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
                text: i18n.tr("Save log")
                anchors.verticalCenter: tcpdumpLabel.verticalCenter
                onClicked: {
                    if (tcpfnText.text == ""){
                        messageDialog.icon = StandardIcon.Critical
                        messageDialog.text = i18n.tr("Please start TCP dump first")
                        messageDialog.visible = true
                    } else {
                        fileDialog.visible = true
                    }
                }
            } 
            FileDialog {
                id: fileDialog
                title: i18n.tr("Please choose a directory for the log")
                folder: shortcuts.documents
                selectMultiple: false
                selectFolder: true
                onAccepted: {
                    var local_path = fileDialog.folder.toString().replace(/file:\/\//, "")
                    cmd_tcpPull.start(applicationDirPath + '/utils/adb', ['pull', tcpfnText.text, local_path])
                    messageDialog.title = i18n.tr("File copy")
                    messageDialog.icon = StandardIcon.Information
                    messageDialog.text = i18n.tr("File copied to: ") + local_path
                    messageDialog.visible = true
                }
                onRejected: {
                    messageDialog.title = i18n.tr("File copy")
                    messageDialog.icon = StandardIcon.Warning
                    messageDialog.text = i18n.tr("Operation cancelled")
                    messageDialog.visible = true
                }
            }
            Text {
                id: tcpfnText
                text: ""
            }
        }
        Row {
            anchors {
                horizontalCenter: parent.horizontalCenter
             }
            Text {
                text: i18n.tr("Event Monitor")
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
                    selectionColor: 'green'
                    wrapMode: TextEdit.WordWrap
                    cursorPosition: sysLog.text.length
                }
            }
        }
    }
}
