import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"
import "../services"

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
    implicitWidth: 310
    implicitHeight: mainCard.implicitHeight

    property bool copiedFeedback: false

    Process {
        id: netSettingsProc
        command: ["plasma-open-settings", "kcm_networkmanagement"]
    }

    function openSettings() {
        popup.visible = false;
        if (netSettingsProc.running) netSettingsProc.running = false;
        netSettingsProc.running = true;
    }

    function copyIp() {
        Quickshell.clipboardText = NetworkService.localIp;
        copiedFeedback = true;
        copyTimer.restart();
    }

    Timer {
        id: copyTimer
        interval: 1800
        onTriggered: popup.copiedFeedback = false
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
                    color: Qt.rgba(Theme.blue.r, Theme.blue.g, Theme.blue.b, 0.15)

                    Text {
                        anchors.centerIn: parent
                        text: NetworkService.interfaceIcon
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 14
                        color: Theme.blue
                    }
                }

                Text {
                    text: "Netzwerk & Internet"
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

            // Connection Status Card
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 52
                radius: 10
                color: Theme.surface0

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 10

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: NetworkService.isWifi ? "WLAN-Verbindung" : "Ethernet LAN"
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            color: Theme.text
                        }

                        Text {
                            text: NetworkService.interfaceName
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            color: Theme.subtext
                        }
                    }

                    // Online/Offline Pill Badge
                    Rectangle {
                        implicitHeight: 22
                        implicitWidth: statusText.implicitWidth + 16
                        radius: 11
                        color: NetworkService.isOnline 
                            ? Qt.rgba(Theme.green.r, Theme.green.g, Theme.green.b, 0.16)
                            : Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, 0.16)
                        border.color: NetworkService.isOnline ? Theme.green : Theme.red
                        border.width: 1

                        Text {
                            id: statusText
                            anchors.centerIn: parent
                            text: NetworkService.isOnline ? "Online" : "Getrennt"
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            color: NetworkService.isOnline ? Theme.green : Theme.red
                        }
                    }
                }
            }

            // Real-Time Speed Row (Download / Upload)
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                // Download Card
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 46
                    radius: 8
                    color: Theme.surface0

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: "󰁅"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 14
                            color: Theme.blue
                        }

                        ColumnLayout {
                            spacing: 1
                            Text { text: "Download"; font.family: Theme.fontFamily; font.pixelSize: 9; color: Theme.subtext }
                            Text { text: NetworkService.downSpeedStr; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text }
                        }
                    }
                }

                // Upload Card
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 46
                    radius: 8
                    color: Theme.surface0

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: "󰁝"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 14
                            color: Theme.green
                        }

                        ColumnLayout {
                            spacing: 1
                            Text { text: "Upload"; font.family: Theme.fontFamily; font.pixelSize: 9; color: Theme.subtext }
                            Text { text: NetworkService.upSpeedStr; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text }
                        }
                    }
                }
            }

            // IP & Gateway Information Card
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 64
                radius: 10
                color: Theme.surface0

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 6

                    // IP Row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: "Lokale IPv4:"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            color: Theme.subtext
                        }

                        Text {
                            text: NetworkService.localIp
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: Theme.text
                            Layout.fillWidth: true
                        }

                        // Copy Button
                        Rectangle {
                            implicitWidth: copyLabel.implicitWidth + 12
                            implicitHeight: 20
                            radius: 10
                            color: copyMouse.containsMouse ? Theme.surface1 : "transparent"
                            border.color: Theme.surface1
                            border.width: 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    text: popup.copiedFeedback ? "󰄬" : "󰅍"
                                    font.family: Theme.iconFontFamily
                                    font.pixelSize: 10
                                    color: popup.copiedFeedback ? Theme.green : Theme.blue
                                }

                                Text {
                                    id: copyLabel
                                    text: popup.copiedFeedback ? "Kopiert!" : "Kopieren"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 9
                                    color: popup.copiedFeedback ? Theme.green : Theme.text
                                }
                            }

                            MouseArea {
                                id: copyMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: popup.copyIp()
                            }
                        }
                    }

                    // Gateway Row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: "Router / GW:"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            color: Theme.subtext
                        }

                        Text {
                            text: NetworkService.gateway
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            color: Theme.subtext
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            // Footer Button: KDE Network Settings
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 32
                radius: 8
                color: settingsMouse.containsMouse ? Theme.surface0 : "transparent"

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "󰒓"
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 12
                        color: Theme.subtext
                    }

                    Text {
                        text: "KDE Netzwerkeinstellungen"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Theme.subtext
                    }
                }

                MouseArea {
                    id: settingsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: popup.openSettings()
                }
            }
        }
    }
}
