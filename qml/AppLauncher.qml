/*
 * This file is part of the Ubuntu Phone pre-loaded app monitoring tool.
 *
 * Copyright 2016 Canonical Ltd.
 * Authors:
 *   Maciej Kisielewski <maciej.kisielewski@canonical.com>
 *   Po-Hsu Lin <po-hsu.lin@canonical.com>
 */

import QtQuick.Controls 1.4
import QtQuick 2.0
import Process 1.0
import QtQuick.Layouts 1.2
import Ubuntu.Components 1.3

Item {
    Component.onCompleted: {
        console.log('App launcher loaded')
        cmd_list.start(applicationDirPath + '/utils/list_app.py', ['--watch'])
        cmd_watch.start(applicationDirPath + '/utils/adb', ['shell', 'ubuntu-app-watch'])
    }
    function readfile() {
        var rawFile = new XMLHttpRequest()
        rawFile.open('GET', '/tmp/app_list', false)
        rawFile.onreadystatechange = function (){
            if(rawFile.readyState == 4){
                if(rawFile.status === 200 || rawFile.status == 0){
                    var allText = rawFile.responseText;
                    var items = allText.toString().replace(/\n$/, "").split('\n');
                    for (var i in items) {
                        var name = items[i].split(',')[0].trim();
                        var keyw = items[i].split(',')[1].trim();
                        var vers = items[i].split(',')[2].trim();
                        var exec = items[i].split(',')[3].trim();
                        var info = items[i].split(',')[4].trim();
                        console.log(name, vers, '-', exec)
                        app_list.append( {'text': name + vers, 'keyword': keyw, 'name': name, 'proc': exec, 'maintainer': info} )
                    }
                    hintText.text = i18n.tr("Ready")
                    hintText.color = "lime"
                }
            }
        }
        rawFile.send(null);
    }
    Process {
        id: cmd_list
        onReadyRead: {
            appList.text = i18n.tr("Current running apps:\n") + readAll();
        }
    }
    function timestamp() {         
        var locale =  Qt.locale()
        var currentTime = new Date()
        return currentTime.toLocaleString(locale, "yyyyMMdd hh:mm:ss")
    }

    Process {
        id: cmd_watch
        onReadyRead: {
            appStatus.text += timestamp() + ' - ' + readAll();
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
            text: i18n.tr("App Launcher")
            font.pointSize: 16
        }
        Flickable {
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true
            contentHeight: appList.contentHeight
            TextEdit {
                id: appList
                text: i18n.tr("Current running apps:\n")
                font.pointSize: 12
                selectionColor: 'green'
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
                //TRANSLATORS: Please leave the ubuntu-app-watch command untranslated
                text: i18n.tr("Status change from ubuntu-app-watch:\n")
                font.pointSize: 12
                selectionColor: 'green'
            }
        }
        Text {
            id: authorLabel
            text: i18n.tr("Maintainers: ")
            font.pointSize: 12
        }
        Text {
            id: authorText
            text: i18n.tr("(Please select an App...)")
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
                    Component.onCompleted: {
                        append({'text': i18n.tr("(Please select an App...)"), 'keyword': '', 'name': '', 'proc': '', 'maintainer': i18n.tr("(Please select an App...)")})
                        readfile()
                    }
                }
                onCurrentIndexChanged: {
                    authorText.text = app_list.get(currentIndex).maintainer
                    console.debug(app_list.get(currentIndex).text + ", " + app_list.get(currentIndex).proc)
                }
            }

            Button{
                id: runButton
                anchors {
                    left: app_cb.right
                    bottom: app_cb.bottom
                    leftMargin: 10
                }
                text: i18n.tr("Start!")
                onClicked: {
                    if (app_cb.currentIndex != 0){
                        console.log("Lauching App: " + app_list.get(app_cb.currentIndex).text)
                        launch_cmd.start(applicationDirPath + '/utils/launch_app.sh', [app_list.get(app_cb.currentIndex).proc])
                        hintText.text = i18n.tr("App monitoring started")
                        hintText.color = ""
                        appNameLabel.text = app_list.get(app_cb.currentIndex).name
                        appKeyLabel.text = app_list.get(app_cb.currentIndex).keyword
                        appProcLabel.text = app_list.get(app_cb.currentIndex).proc
                    } else {
                        console.log("Please select an app to start")
                        hintText.text = i18n.tr("Please select an app to start")
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
                text: i18n.tr("Status: ")
            }
            Text {
                id: hintText
                anchors {
                    left: statusText.right
                    verticalCenter: app_cb.verticalCenter
                    leftMargin: 5
                }
                text: i18n.tr("Loading app list...")
                color: "red"
            }

        }
    }
}

