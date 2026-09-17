import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "theme"
import "components"

ShellRoot {
    id: root

    PanelWindow {
        id: barWindow

        // Floating pill bar anchored to top with margins
        anchors {
            top: true
            left: true
            right: true
        }
        margins {
            top: 8
            left: 14
            right: 14
        }
        implicitHeight: 46
        color: "transparent"

        // Place on top layer in Wayland
        WlrLayershell.layer: WlrLayer.Top

        // Glassmorphic Floating Island Container
        Rectangle {
            id: barContainer
            anchors.fill: parent
            radius: 23
            color: Theme.glassBg
            border.color: Theme.glassBorder
            border.width: 1

            // Subtle drop-shadow simulation with gradient/border
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: "transparent"
                border.color: "#10ffffff"
                border.width: 1
                anchors.margins: 1
            }

            // Left Section: Launcher & System Stats
            RowLayout {
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                LauncherButton {}
                SysInfoWidget {}
            }

            // Center Section: Clock & Date
            ClockWidget {
                anchors.centerIn: parent
            }

            // Right Section: Media Player & Volume
            RowLayout {
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                MediaWidget {}
                VolumeWidget {}
            }
        }
    }
}
