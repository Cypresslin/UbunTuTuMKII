import QtQuick 2.0
import Process 1.0
import "colour.js" as Colour
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2


Item {
    Component.onCompleted: {
        console.log('Check Config')
        cmd_mode.start(applicationDirPath + '/utils/check_config.py', ['--check-mode', '--app', appNameLabel.text])
        cmd_proc.start(applicationDirPath + '/utils/check_config.py', ['--check-process', '--app', appNameLabel.text])
        cmd_policy.start(applicationDirPath + '/utils/check_config.py', ['--check-policy', '--app', appNameLabel.text])
    }
    Process {
        id: cmd_mode
        onReadyRead: {
            var result = readAll().toString().replace(/\n$/, "")
            modeText.text = result
            if (result.indexOf("Enforcement") >= 0){
                modeText.color = "green"
            } else {
                modeText.color = "red"
            }
            console.log(modeText.text)
        }
    }
    Process {
        id: cmd_proc
        onReadyRead: {
            var result = readAll().toString().replace(/\n$/, "")
            procText.text = result
            if (result.indexOf("YES") >= 0){
                procText.color = "green"
            } else {
                procText.color = "red"
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
            text: appNameLabel.text
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
                cmd_rules.start(applicationDirPath + '/utils/check_config.py', ['--copy-rules', '--app', appNameLabel.text])
            }
        }
        Process {
            id: cmd_rules
            onReadyRead: {
                var result = readAll().toString().replace(/\n$/, "")
                if (result.indexOf("Error:") >= 0){
                    messageDialog.icon = StandardIcon.Critical
                    messageDialog.text = "Failed to copy file"
                    console.log(messageDialog.text)
                    messageDialog.visible = true
                } else {
                    messageDialog.icon = StandardIcon.Information
                    messageDialog.text = "File copied to:" + applicationDirPath + '/'
                    console.log(messageDialog.text)
                    messageDialog.visible = true
                }
            }
        }   

        MessageDialog {
            id: messageDialog
            title: "File copy"
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
            id: cameraCb
            text: i18n.tr("CameraService")
            checked: true
        }
        CheckBox {
            id: audioCb
            text: i18n.tr("PulseAudio")
            checked: true
        }
        CheckBox {
            id: locationCb
            text: i18n.tr("UbuntuLocationService")
            checked: true
        }
        Button {
            id: runButton
            text: i18n.tr("Start!")
            onClicked: {
                var permissions = []
                if (cameraCb.checked) {
                    permissions.push(cameraCb.text)
                }
                if (audioCb.checked) {
                    permissions.push(audioCb.text)
                }
                if (locationCb.checked) {
                    permissions.push(locationCb.text)
                }
                if (permissions.length > 0){
                    cmd_reset.start(applicationDirPath + '/utils/reset_trust_store.sh', permissions)
                    trustText.text = i18n.tr("Permission resetted")
                    trustText.color = "green"
                } else {
                    trustText.text = i18n.tr("No target selected")
                    trustText.color = "red"
                }
            }
        }
        Process {
            id: cmd_reset
            onReadyRead: {
                console.log(readAll())
            }
        }
        Text {
            id: trustText
            anchors {
                left: runButton.right
                leftMargin: units.gu(2)
            }
            text: i18n.tr("Ready")
            color: "green"
        }
    }
}
