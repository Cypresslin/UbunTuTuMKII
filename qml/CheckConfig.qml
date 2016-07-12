/*
 * This file is part of the Ubuntu Phone pre-loaded app monitoring tool.
 *
 * Copyright 2016 Canonical Ltd.
 * Authors:
 *   Maciej Kisielewski <maciej.kisielewski@canonical.com>
 *   Po-Hsu Lin <po-hsu.lin@canonical.com>
 */
import QtQuick 2.0
import Process 1.0
import "colour.js" as Colour
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import Ubuntu.Components 1.3


Item {
    Component.onCompleted: {
        console.log('Check Config')
        cmd_mode.start(applicationDirPath + '/utils/check_config.py', ['--check-mode', '--proc', appProcLabel.text])
        cmd_proc.start(applicationDirPath + '/utils/check_config.py', ['--check-process', '--proc', appProcLabel.text])
        cmd_policy.start(applicationDirPath + '/utils/check_config.py', ['--check-policy', '--proc', appProcLabel.text])
    }
    Process {
        id: cmd_mode
        onReadyRead: {
            var result = readAll().toString().replace(/\n$/, "")
            modeText.text = result
            if (result.indexOf("Error") >= 0){
                modeText.color = "red"
            } else {
                modeText.color = "green"
            }
            console.log(modeText.text)
        }
    }
    Process {
        id: cmd_proc
        onReadyRead: {
            var result = readAll().toString().replace(/\n$/, "")
            procText.text = result
            if (result.indexOf("Error") >= 0){
                procText.color = "red"
            } else {
                procText.color = "green"
            }
            console.log("Process is Confined: " + result)
        }
    }
    Process {
        id: cmd_policy
        onReadyRead: {
            policyLog.text = readAll()
            console.log(policyLog.text)
        }
    }

    ColumnLayout {
        id: mainCol
        anchors {
            fill: parent
            rightMargin: 30
            leftMargin: 40
            topMargin: 30
            bottomMargin: 50
        }
        spacing: units.gu(5)
        Text {
            id: title
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            text: i18n.tr("App Config Check")
            font.pointSize: 16
        }
        Text {
            id: appLabel
            text: i18n.tr("Checking: ")
            font.bold: true
        }
        Text {
            id: appNameText
            text: appProcLabel.text
            color: "green"
            anchors {
                left: appLabel.right
                top: appLabel.top
            }
        }
        Text {
            id: modeLabel
            text: i18n.tr("AppArmor Profile: ")
            font.bold: true
            anchors {
                top: appLabel.bottom
            }
        }
        Text {
            id: modeText
            text: i18n.tr("Result")
            anchors {
                left: modeLabel.right
                top: modeLabel.top 
            }
        }
        Text {
            id: procLabel
            text: i18n.tr("Process is Confined: ")
            font.bold: true
            anchors {
                left: parent.horizontalCenter
                top: modeLabel.top
            }
        }
        Text {
            id: procText
            text: i18n.tr("Result")
            anchors {
                left: procLabel.right
                top: modeLabel.top
            }
        }
        Text {
            id: policyLabel
            text: i18n.tr("AppArmor Policy:")
            font.bold: true
            anchors {
                left: parent.left
                top: procLabel.bottom
            }
        }
        
        Flickable {
            id: policyFlick
            Layout.fillHeight: false
            Layout.fillWidth: true
            clip: true
            anchors {
                top: policyLabel.bottom
            }
            height: units.gu(7)
            contentHeight: policyLog.contentHeight
            TextEdit {
                id: policyLog
                text: i18n.tr('Running Checker...')
                font.pointSize: 10
                selectionColor: Colour.palette['Green']
                wrapMode: TextEdit.WordWrap
                cursorPosition: policyLog.text.length
            }
        }
        Text {
            id: rulesLabel
            text: i18n.tr("AppArmor Final Rules:")
            font.bold: true
            anchors {
                top: policyFlick.bottom
            }
        }
        Button {
            id: cpButton
            text: i18n.tr("Copy")
            anchors {
                verticalCenter: rulesLabel.verticalCenter
                top: policyFlick.bottom
                left: rulesLabel.right
            }
            onClicked: {
                cmd_rules.start(applicationDirPath + '/utils/check_config.py', ['--copy-rules', '--proc', appProcLabel.text])
            }
        }
        Process {
            id: cmd_rules
            onReadyRead: {
                var result = readAll().toString().replace(/\n$/, "")
                messageDialog.title = i18n.tr("File copy")
                if (result.indexOf("Error:") >= 0){
                    messageDialog.icon = StandardIcon.Critical
                    messageDialog.text = i18n.tr("Failed to copy file")
                    console.log(messageDialog.text)
                } else {
                    messageDialog.icon = StandardIcon.Information
                    messageDialog.text = i18n.tr("File copied to: ") + applicationDirPath + '/'
                    console.log(messageDialog.text)
                }
                messageDialog.visible = true
            }
        }   

        MessageDialog {
            id: messageDialog
        }
    }
    RowLayout {
        anchors {
            top: mainCol.bottom
            left: mainCol.left
        }
        Text{
            id: resetLabel
            text: i18n.tr("Reset Permissions:")
            font.bold: true
        }
        CheckBox {
            id: cameraCB
            checked: true
        }
        Label {
            id: cameraCBText
            text: i18n.tr("CameraService")
            anchors.verticalCenter: parent.verticalCenter
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    cameraCB.checked = !cameraCB.checked
                }
            }
        }
        CheckBox {
            id: audioCB
            checked: true
        }
        Label {
            id: audioCBText
            text: i18n.tr("PulseAudio")
            anchors.verticalCenter: parent.verticalCenter
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    audioCB.checked = !audioCB.checked
                }
            }
        }
        CheckBox {
            id: locationCB
            checked: true
        }
        Label {
            id: locationCBText
            text: i18n.tr("UbuntuLocationService")
            anchors.verticalCenter: parent.verticalCenter
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    locationCB.checked = !locationCB.checked
                }
            }
        }

        Button {
            id: runButton
            text: i18n.tr("Start!")
            onClicked: {
                var permissions = []
                if (cameraCB.checked) {
                    permissions.push(cameraCBText.text)
                }
                if (audioCB.checked) {
                    permissions.push(audioCBText.text)
                }
                if (locationCB.checked) {
                    permissions.push(locationCBText.text)
                }
                messageDialog.title = i18n.tr("Reset Permissions")
                if (permissions.length > 0 && appProcLabel.text != 'APP NAME'){
                    messageDialog.icon = StandardIcon.Information
                    messageDialog.text = i18n.tr("Permission restted for: ") + permissions
                    cmd_reset.start(applicationDirPath + '/utils/reset_trust_store.sh', permissions)
                } else {
                    messageDialog.icon = StandardIcon.Critical
                    messageDialog.text = i18n.tr("No target App / Permission selected")
                    console.log(messageDialog.text)
                }
                messageDialog.visible = true
            }
        }
        Process {
            id: cmd_reset
            onReadyRead: {
                console.log(readAll())
            }
        }
    }
}
