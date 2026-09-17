import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme"

Pill {
    id: root
    clickable: true
    implicitHeight: 34
    implicitWidth: 38

    Process {
        id: launcherProc
        command: ["krunner"]
    }

    onClicked: {
        launcherProc.running = true
    }

    Text {
        anchors.centerIn: parent
        text: "❖"
        color: root.hovered ? Theme.mauve : Theme.blue
        font.pixelSize: 18
        font.bold: true

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }
}
