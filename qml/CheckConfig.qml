import QtQuick 2.0
import Process 1.0
import "colour.js" as Colour
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2


Item {
    Component.onCompleted: {
        console.log('Check Config')
        cmd_name.start(applicationDirPath + '/utils/check_config.py', ['--app-name'])
        cmd_mode.start(applicationDirPath + '/utils/check_config.py', ['--check-mode'])
        cmd_proc.start(applicationDirPath + '/utils/check_config.py', ['--check-process'])
        cmd_policy.start(applicationDirPath + '/utils/check_config.py', ['--check-policy'])
        cmd_rules.start(applicationDirPath + '/utils/check_config.py', ['--check-rules'])
    }
    Process {
        id: cmd_name
        onReadyRead: {
            appText.text = readAll().toString().replace(/\n$/, "")
            console.log("Checking: " + appText.text)
        }
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
    Process {
        id: cmd_rules
        onReadyRead: {
            rulesLog.text += readAll()
            console.log(rulesLog.text)
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
            text: "App Config Check"
            font.pointSize: 16
        }
        Text {
            id: appLabel
            text: "Checking: "
            font.bold: true
        }
        Text {
            id: appText
            text: "App Name"
            color: "green"
            anchors {
                left: appLabel.right
                top: appLabel.top
            }
        }
        Text {
            id: modeLabel
            text: "AppArmor Profile: "
            font.bold: true
            anchors {
                top: appLabel.bottom
            }
        }
        Text {
            id: modeText
            text: "Result"
            anchors {
                left: modeLabel.right
                top: modeLabel.top 
            }
        }
        Text {
            id: procLabel
            text: "Process is Confined: "
            font.bold: true
            anchors {
                left: parent.horizontalCenter
                top: modeLabel.top
            }
        }
        Text {
            id: procText
            text: "Result"
            anchors {
                left: procLabel.right
                top: modeLabel.top
            }
        }
        Text {
            id: policyLabel
            text: "AppArmor Policy:"
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
                text: 'Running Checker...'
                font.pointSize: 10
                selectionColor: Colour.palette['Green']
                wrapMode: TextEdit.WordWrap
                cursorPosition: policyLog.text.length
            }
        }
        Text {
            id: rulesLabel
            text: "AppArmor Final Rules:"
            font.bold: true
            anchors {
                top: policyFlick.bottom
            }
        }
        Flickable {
            id: rulesFlick
//            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true
            anchors {
                top: rulesLabel.bottom
            }
            height: units.gu(55)
            contentHeight: rulesLog.contentHeight
            TextEdit {
                id: rulesLog
                text: 'Running Checker...'
                font.pointSize: 10
                selectionColor: Colour.palette['Green']
                wrapMode: TextEdit.WordWrap
                cursorPosition: rulesLog.text.length
            }
        }
    }
}
