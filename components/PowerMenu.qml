import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

PopupWindow {
    id: popup

    property var anchorItem: null
    property var anchorWindow: null

    anchor {
        window: popup.anchorWindow
        item: popup.anchorItem
        edges: Edges.Bottom | Edges.Left
        gravity: Edges.Bottom | Edges.Right
        margins.top: 8
    }

    grabFocus: true
    visible: false
    color: "transparent"
    implicitWidth: 260
    implicitHeight: mainCard.implicitHeight

    Process {
        id: execProc
        command: ["sh", "-c", "true"]
    }

    function runCommand(cmd) {
        popup.visible = false;
        execProc.command = ["sh", "-c", cmd];
        execProc.running = true;
    }

    Rectangle {
        id: mainCard
        anchors.fill: parent
        radius: Theme.radiusCard
        color: "#f21e1e2e" // High-opacity Catppuccin Mocha base
        border.color: Theme.glassBorder
        border.width: 1
        clip: true

        implicitHeight: contentCol.implicitHeight + 24

        // Inner subtle rim highlight
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.color: "#18ffffff"
            border.width: 1
            anchors.margins: 1
        }

        ColumnLayout {
            id: contentCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 12
            spacing: 6

            // Header
            RowLayout {
                Layout.fillWidth: true
                Layout.bottomMargin: 4
                spacing: 8

                Rectangle {
                    implicitWidth: 26
                    implicitHeight: 26
                    radius: 13
                    color: Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, 0.15)

                    Text {
                        anchors.centerIn: parent
                        text: "󰐥"
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 14
                        color: Theme.red
                    }
                }

                Text {
                    text: "Power & Sitzung"
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    color: Theme.text
                    Layout.fillWidth: true
                }

                Rectangle {
                    implicitWidth: 22
                    implicitHeight: 22
                    radius: 11
                    color: closeMouse.containsMouse ? Theme.surface1 : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "󰅖"
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 12
                        color: Theme.subtext
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popup.visible = false
                    }
                }
            }

            // Separator
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.surface0
            }

            // Action Items
            // 1. Herunterfahren
            Rectangle {
                id: shutdownItem
                Layout.fillWidth: true
                implicitHeight: 44
                radius: 10
                color: shutdownMouse.containsMouse ? Theme.surface0 : "transparent"
                border.color: shutdownMouse.containsMouse ? Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, 0.4) : "transparent"
                border.width: 1

                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 120 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 10

                    Rectangle {
                        implicitWidth: 30
                        implicitHeight: 30
                        radius: 8
                        color: Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, 0.15)

                        Text {
                            anchors.centerIn: parent
                            text: "󰐥"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 15
                            color: Theme.red
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: "Herunterfahren"
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            color: shutdownMouse.containsMouse ? Theme.red : Theme.text
                        }

                        Text {
                            text: "Computer ausschalten"
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            color: Theme.subtext
                        }
                    }
                }

                MouseArea {
                    id: shutdownMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: popup.runCommand("qdbus org.kde.Shutdown /Shutdown logoutAndShutdown || systemctl poweroff")
                }
            }

            // 2. Neu starten
            Rectangle {
                id: rebootItem
                Layout.fillWidth: true
                implicitHeight: 44
                radius: 10
                color: rebootMouse.containsMouse ? Theme.surface0 : "transparent"
                border.color: rebootMouse.containsMouse ? Qt.rgba(Theme.peach.r, Theme.peach.g, Theme.peach.b, 0.4) : "transparent"
                border.width: 1

                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 120 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 10

                    Rectangle {
                        implicitWidth: 30
                        implicitHeight: 30
                        radius: 8
                        color: Qt.rgba(Theme.peach.r, Theme.peach.g, Theme.peach.b, 0.15)

                        Text {
                            anchors.centerIn: parent
                            text: "󰑐"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 15
                            color: Theme.peach
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: "Neu starten"
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            color: rebootMouse.containsMouse ? Theme.peach : Theme.text
                        }

                        Text {
                            text: "System neu starten"
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            color: Theme.subtext
                        }
                    }
                }

                MouseArea {
                    id: rebootMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: popup.runCommand("qdbus org.kde.Shutdown /Shutdown logoutAndReboot || systemctl reboot")
                }
            }

            // 3. Energiesparen (Sleep)
            Rectangle {
                id: sleepItem
                Layout.fillWidth: true
                implicitHeight: 44
                radius: 10
                color: sleepMouse.containsMouse ? Theme.surface0 : "transparent"
                border.color: sleepMouse.containsMouse ? Qt.rgba(Theme.blue.r, Theme.blue.g, Theme.blue.b, 0.4) : "transparent"
                border.width: 1

                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 120 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 10

                    Rectangle {
                        implicitWidth: 30
                        implicitHeight: 30
                        radius: 8
                        color: Qt.rgba(Theme.blue.r, Theme.blue.g, Theme.blue.b, 0.15)

                        Text {
                            anchors.centerIn: parent
                            text: "󰒲"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 15
                            color: Theme.blue
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: "Energiesparen"
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            color: sleepMouse.containsMouse ? Theme.blue : Theme.text
                        }

                        Text {
                            text: "In den Standby-Modus"
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            color: Theme.subtext
                        }
                    }
                }

                MouseArea {
                    id: sleepMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: popup.runCommand("systemctl suspend")
                }
            }

            // 4. Sperren (Lock Screen)
            Rectangle {
                id: lockItem
                Layout.fillWidth: true
                implicitHeight: 44
                radius: 10
                color: lockMouse.containsMouse ? Theme.surface0 : "transparent"
                border.color: lockMouse.containsMouse ? Qt.rgba(Theme.mauve.r, Theme.mauve.g, Theme.mauve.b, 0.4) : "transparent"
                border.width: 1

                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 120 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 10

                    Rectangle {
                        implicitWidth: 30
                        implicitHeight: 30
                        radius: 8
                        color: Qt.rgba(Theme.mauve.r, Theme.mauve.g, Theme.mauve.b, 0.15)

                        Text {
                            anchors.centerIn: parent
                            text: "󰌾"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 15
                            color: Theme.mauve
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: "Sperren"
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            color: lockMouse.containsMouse ? Theme.mauve : Theme.text
                        }

                        Text {
                            text: "Bildschirm sofort sperren"
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            color: Theme.subtext
                        }
                    }
                }

                MouseArea {
                    id: lockMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: popup.runCommand("loginctl lock-session")
                }
            }

            // 5. Abmelden (Logout)
            Rectangle {
                id: logoutItem
                Layout.fillWidth: true
                implicitHeight: 44
                radius: 10
                color: logoutMouse.containsMouse ? Theme.surface0 : "transparent"
                border.color: logoutMouse.containsMouse ? Qt.rgba(Theme.yellow.r, Theme.yellow.g, Theme.yellow.b, 0.4) : "transparent"
                border.width: 1

                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 120 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 10

                    Rectangle {
                        implicitWidth: 30
                        implicitHeight: 30
                        radius: 8
                        color: Qt.rgba(Theme.yellow.r, Theme.yellow.g, Theme.yellow.b, 0.15)

                        Text {
                            anchors.centerIn: parent
                            text: "󰍃"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 15
                            color: Theme.yellow
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: "Abmelden"
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            color: logoutMouse.containsMouse ? Theme.yellow : Theme.text
                        }

                        Text {
                            text: "Benutzersitzung beenden"
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            color: Theme.subtext
                        }
                    }
                }

                MouseArea {
                    id: logoutMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: popup.runCommand("qdbus org.kde.Shutdown /Shutdown logout")
                }
            }

            // Footer / KDE Dialog Option
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.surface0
                Layout.topMargin: 4
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 32
                radius: 8
                color: kdePromptMouse.containsMouse ? Theme.surface0 : "transparent"

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "󰍜"
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 13
                        color: Theme.subtext
                    }

                    Text {
                        text: "KDE Systemdialog anzeigen"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Theme.subtext
                    }
                }

                MouseArea {
                    id: kdePromptMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: popup.runCommand("qdbus org.kde.LogoutPrompt /LogoutPrompt promptAll")
                }
            }
        }
    }
}
