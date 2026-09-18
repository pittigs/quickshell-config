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
        id: execProc
        command: ["sh", "-c", "true"]
    }

    function runCmd(cmd) {
        if (execProc.running) execProc.running = false;
        execProc.command = ["sh", "-c", cmd];
        execProc.running = true;
    }

    onClicked: {
        runCmd("qdbus org.kde.krunner /App display || krunner");
    }

    onRightClicked: {
        runCmd("qdbus org.kde.plasmashell /PlasmaShell activateLauncherMenu || qdbus org.kde.krunner /App display || krunner");
    }

    Text {
        anchors.centerIn: parent
        text: "❖"
        color: root.hovered ? Theme.mauve : Theme.blue
        font.pixelSize: 17
        font.bold: true

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }
}
