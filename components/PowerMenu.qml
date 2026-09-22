import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

PopupWindow {
    id: popup

    property var anchorItem: null
    property var anchorWindow: null

    property string confirmingAction: "" // "" | "shutdown" | "reboot"

    onVisibleChanged: {
        if (!visible) {
            confirmingAction = "";
        }
    }

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
        stderr: StdioCollector {
            onTextChanged: {
                if (text && text.trim().length > 0) {
                    console.warn("[PowerMenu] Error:", text.trim());
                }
            }
        }
    }

    function runCommand(cmd) {
        popup.visible = false;
        popup.confirmingAction = "";
        if (execProc.running) execProc.running = false;
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

        // Scale & Opacity smooth entrance animation
        scale: popup.visible ? 1.0 : 0.95
        opacity: popup.visible ? 1.0 : 0.0
        Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

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
                    text: popup.confirmingAction !== "" ? "Bestätigung" : "Power & Sitzung"
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

            // ==========================================
            // INLINE CONFIRMATION VIEW (When user clicked Shutdown or Reboot)
            // ==========================================
            ColumnLayout {
                Layout.fillWidth: true
                visible: popup.confirmingAction !== ""
                spacing: 10

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 70
                    radius: 10
                    color: Theme.surface0

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: popup.confirmingAction === "shutdown" ? "Wirklich herunterfahren?" : "Wirklich neu starten?"
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.Bold
                            color: popup.confirmingAction === "shutdown" ? Theme.red : Theme.peach
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: popup.confirmingAction === "shutdown" ? "Ungespeicherte Daten gehen verloren." : "Das System wird neu geladen."
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            color: Theme.subtext
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    // Primary Confirm Button
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 34
                        radius: 8
                        color: popup.confirmingAction === "shutdown" ? Theme.red : Theme.peach

                        Text {
                            anchors.centerIn: parent
                            text: popup.confirmingAction === "shutdown" ? "Ja, Ausschalten" : "Ja, Neu starten"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: Theme.crust
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (popup.confirmingAction === "shutdown") {
                                    popup.runCommand("systemctl poweroff || loginctl poweroff || poweroff");
                                } else {
                                    popup.runCommand("systemctl reboot || loginctl reboot || reboot");
                                }
                            }
                        }
                    }

                    // Cancel Button
                    Rectangle {
                        Layout.preferredWidth: 80
                        implicitHeight: 34
                        radius: 8
                        color: cancelMouse.containsMouse ? Theme.surface2 : Theme.surface1

                        Text {
                            anchors.centerIn: parent
                            text: "Abbrechen"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            color: Theme.text
                        }

                        MouseArea {
                            id: cancelMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: popup.confirmingAction = ""
                        }
                    }
                }
            }

            // ==========================================
            // MAIN ACTION ITEMS (When not in confirmation)
            // ==========================================
            ColumnLayout {
                Layout.fillWidth: true
                visible: popup.confirmingAction === ""
                spacing: 6

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
                        onClicked: popup.confirmingAction = "shutdown"
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
                        onClicked: popup.confirmingAction = "reboot"
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
                        onClicked: popup.runCommand("qdbus-qt6 org.kde.Shutdown /Shutdown org.kde.Shutdown.logout 2>/dev/null || loginctl terminate-session ${XDG_SESSION_ID:-self} || loginctl terminate-user $USER")
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
                        onClicked: popup.runCommand("qdbus-qt6 org.kde.LogoutPrompt /LogoutPrompt promptAll 2>/dev/null || qdbus org.kde.LogoutPrompt /LogoutPrompt promptAll 2>/dev/null")
                    }
                }
            }
        }
    }
}
