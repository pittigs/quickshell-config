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
        edges: Edges.Bottom | Edges.Right
        gravity: Edges.Bottom | Edges.Left
        margins.top: 8
    }

    grabFocus: true
    visible: false
    color: "transparent"
    implicitWidth: 290
    implicitHeight: mainCard.implicitHeight

    property bool nightLightActive: false
    property bool dndActive: false

    Process {
        id: execProc
        command: ["sh", "-c", "true"]
    }

    function runCmd(cmd) {
        if (execProc.running) execProc.running = false;
        execProc.command = ["sh", "-c", cmd];
        execProc.running = true;
    }

    function toggleNightLight() {
        nightLightActive = !nightLightActive;
        const val = nightLightActive ? "true" : "false";
        runCmd("kwriteconfig6 --file kwinrc --group NightColor --key Active " + val + " && qdbus org.kde.KWin /KWin reconfigure");
    }

    function toggleDnd() {
        dndActive = !dndActive;
        const val = dndActive ? "true" : "false";
        runCmd("kwriteconfig6 --file plasmanotifyrc --group DoNotDisturb --key notificationSoundMuted " + val);
    }

    function takeScreenshot(mode) {
        popup.visible = false;
        if (mode === "region") {
            runCmd("spectacle -r");
        } else {
            runCmd("spectacle -f");
        }
    }

    Rectangle {
        id: mainCard
        anchors.fill: parent
        radius: Theme.radiusCard
        color: "#f21e1e2e"
        border.color: Theme.glassBorder
        border.width: 1
        clip: true

        implicitHeight: contentCol.implicitHeight + 24

        // Inner rim highlight
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
            anchors.margins: 14
            spacing: 12

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    implicitWidth: 26
                    implicitHeight: 26
                    radius: 13
                    color: Qt.rgba(Theme.mauve.r, Theme.mauve.g, Theme.mauve.b, 0.15)

                    Text {
                        anchors.centerIn: parent
                        text: "󰍜"
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 14
                        color: Theme.mauve
                    }
                }

                Text {
                    text: "Schnelleinstellungen"
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

            // Quick Toggles Grid (2x2)
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 8
                rowSpacing: 8

                // 1. Nachtmodus (Night Light)
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 52
                    radius: 10
                    color: popup.nightLightActive ? Qt.rgba(Theme.peach.r, Theme.peach.g, Theme.peach.b, 0.18) : Theme.surface0
                    border.color: popup.nightLightActive ? Theme.peach : "transparent"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        Text {
                            text: "󰃠"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 18
                            color: popup.nightLightActive ? Theme.peach : Theme.subtext
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                text: "Nachtmodus"
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: popup.nightLightActive ? Theme.peach : Theme.text
                            }

                            Text {
                                text: popup.nightLightActive ? "Aktiviert" : "Aus"
                                font.family: Theme.fontFamily
                                font.pixelSize: 9
                                color: Theme.subtext
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popup.toggleNightLight()
                    }
                }

                // 2. Nicht stören (DND)
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 52
                    radius: 10
                    color: popup.dndActive ? Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, 0.18) : Theme.surface0
                    border.color: popup.dndActive ? Theme.red : "transparent"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        Text {
                            text: popup.dndActive ? "󰂛" : "󰂚"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 18
                            color: popup.dndActive ? Theme.red : Theme.subtext
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                text: "Nicht stören"
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: popup.dndActive ? Theme.red : Theme.text
                            }

                            Text {
                                text: popup.dndActive ? "Stumm" : "Normal"
                                font.family: Theme.fontFamily
                                font.pixelSize: 9
                                color: Theme.subtext
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popup.toggleDnd()
                    }
                }

                // 3. Screenshot Bereich
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 52
                    radius: 10
                    color: shotRegionMouse.containsMouse ? Theme.surface1 : Theme.surface0

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        Text {
                            text: "󰄀"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 18
                            color: Theme.blue
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                text: "Bereich"
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: Theme.text
                            }

                            Text {
                                text: "Screenshot"
                                font.family: Theme.fontFamily
                                font.pixelSize: 9
                                color: Theme.subtext
                            }
                        }
                    }

                    MouseArea {
                        id: shotRegionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popup.takeScreenshot("region")
                    }
                }

                // 4. Screenshot Vollbild
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 52
                    radius: 10
                    color: shotFullMouse.containsMouse ? Theme.surface1 : Theme.surface0

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        Text {
                            text: "󰹑"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 18
                            color: Theme.green
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                text: "Vollbild"
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: Theme.text
                            }

                            Text {
                                text: "Bildschirmfoto"
                                font.family: Theme.fontFamily
                                font.pixelSize: 9
                                color: Theme.subtext
                            }
                        }
                    }

                    MouseArea {
                        id: shotFullMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popup.takeScreenshot("fullscreen")
                    }
                }
            }

            // Divider Line
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.surface0
            }

            // System Shortcuts Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                // KDE System Settings
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 32
                    radius: 8
                    color: sysSetMouse.containsMouse ? Theme.surface0 : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        Text {
                            text: "󰒓"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 13
                            color: Theme.subtext
                        }

                        Text {
                            text: "KDE Systemeinstellungen"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            color: Theme.text
                            Layout.fillWidth: true
                        }
                    }

                    MouseArea {
                        id: sysSetMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            popup.visible = false;
                            popup.runCmd("systemsettings");
                        }
                    }
                }

                // KDE System Monitor
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 32
                    radius: 8
                    color: sysMonMouse.containsMouse ? Theme.surface0 : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        Text {
                            text: "󰍜"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 13
                            color: Theme.subtext
                        }

                        Text {
                            text: "KDE Systemmonitor"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            color: Theme.text
                            Layout.fillWidth: true
                        }
                    }

                    MouseArea {
                        id: sysMonMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            popup.visible = false;
                            popup.runCmd("plasma-systemmonitor");
                        }
                    }
                }
            }
        }
    }
}
