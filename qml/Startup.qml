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
        console.log('Initialization complete')
        cmd_app_list.start(applicationDirPath + '/utils/list_app.py', ['--list', '--save'])
    }
    Process {
        id: cmd_app_list
        onReadyRead: {
            console.log(readAll())
            loader.source = "AppLauncher.qml";
        }
    }

    Column {
        id: mainCol
        anchors { 
            fill: parent
            margins: 30
            verticalCenter: parent.verticalCenter
        }
        spacing: units.gu(2)
        Row {
            Text {
                text: i18n.tr("Initializating...")
                font.pointSize: 16
            }
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
