//@ pragma UseQApplication
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "theme"
import "components"

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: barWindow

                required property var modelData
                screen: modelData

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

                    // Left Section: App Launcher, Workspaces, Active Window, Power & System Stats
                    RowLayout {
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        LauncherButton {}
                        WorkspaceWidget {}
                        ActiveWindowWidget {}
                        PowerButton { parentWindow: barWindow }
                        SysInfoWidget { parentWindow: barWindow }
                    }

                    // Center Section: Weather & Clock/Date
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        WeatherWidget { parentWindow: barWindow }
                        ClockWidget { parentWindow: barWindow }
                    }

                    // Right Section: Media, Notes, QuickSettings, Network, Tray, Mic & Volume
                    RowLayout {
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        MediaWidget { parentWindow: barWindow }
                        NotesWidget { parentWindow: barWindow }
                        QuickSettingsWidget { parentWindow: barWindow }
                        NetworkWidget { parentWindow: barWindow }
                        TrayWidget { parentWindow: barWindow }
                        MicWidget { parentWindow: barWindow }
                        VolumeWidget { parentWindow: barWindow }
                    }
                }
            }
        }
    }
}
