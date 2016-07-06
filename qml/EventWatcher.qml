import QtQuick 2.0
import Process 1.0
import "colour.js" as Colour
import QtQuick.Dialogs 1.2
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.2


Item {
    Component.onCompleted: {
        console.log('Event Watcher loaded')
          cmd_event.start(applicationDirPath + '/utils/event_watcher.py', ['--app', appNameLabel.text])
    }
    Process {
        id: cmd_event
        onReadyRead: {
            var string = readAll()
            eventLog.text += string
            console.log(eventLog.text)
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
            anchors {
                horizontalCenter: parent.horizontalCenter
             }
            Text {
                text: i18n.tr('Senitive Event Monitor')
                font.pointSize: 16
            }
        }
        Row {
            Flickable {
                contentHeight: eventLog.contentHeight
                width: mainCol.width
                height: 600
                clip: true

                TextEdit {
                    id: eventLog
                    anchors.fill: parent
                    font.pointSize: 10
                    selectionColor: Colour.palette['Green']
                    wrapMode: TextEdit.WordWrap
                    cursorPosition: eventLog.text.length
                }
            }
        }
        Row {
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: i18n.tr('Note: Ubuntu Phone Location Service does not distinguish data from GPS/AGPS')
            }
        }
    }
}
