import QtQuick
import QtQuick.Layouts
import "../theme"

Pill {
    id: root

    clickable: true
    implicitHeight: 34
    implicitWidth: contentLayout.implicitWidth + 24

    property bool showDetails: false
    property var currentTime: new Date()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.currentTime = new Date()
        }
    }

    onClicked: {
        root.showDetails = !root.showDetails
    }

    RowLayout {
        id: contentLayout
        anchors.centerIn: parent
        spacing: 8

        Text {
            text: ""
            font.family: Theme.fontFamily
            font.pixelSize: 13
            color: root.hovered ? Theme.mauve : Theme.blue

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }

        Text {
            text: Qt.formatDateTime(root.currentTime, "ddd, dd. MMM")
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.Medium
            color: Theme.subtext
        }

        Rectangle {
            implicitWidth: 1
            implicitHeight: 12
            color: Theme.surface1
        }

        Text {
            text: root.showDetails 
                ? Qt.formatDateTime(root.currentTime, "HH:mm:ss")
                : Qt.formatDateTime(root.currentTime, "HH:mm")
            font.family: Theme.fontFamily
            font.pixelSize: 13
            font.weight: Font.Bold
            color: Theme.text
        }
    }
}
