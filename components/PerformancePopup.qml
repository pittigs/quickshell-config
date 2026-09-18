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

    // Hardware stats mapped from SysInfoService
    readonly property string cpuPct: SysInfoService.cpuPercent
    readonly property real cpuFraction: SysInfoService.cpuFraction
    readonly property string cpuTemp: SysInfoService.cpuTemp
    readonly property string ramPct: SysInfoService.ramPercent
    readonly property real ramFraction: SysInfoService.ramFraction
    readonly property string ramUsedGB: SysInfoService.ramUsedGB
    readonly property string ramTotalGB: SysInfoService.ramTotalGB
    readonly property string gpuTemp: SysInfoService.gpuTemp
    readonly property string gpuPct: SysInfoService.gpuPercent
    readonly property real gpuFraction: SysInfoService.gpuFraction
    readonly property string vramUsedGB: SysInfoService.vramUsedGB
    readonly property string vramTotalGB: SysInfoService.vramTotalGB
    readonly property string gpuPowerW: SysInfoService.gpuPowerW

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
    implicitWidth: 350
    implicitHeight: mainCard.implicitHeight

    Process {
        id: sysMonProc
        command: ["plasma-systemmonitor"]
    }

    function openSystemMonitor() {
        popup.visible = false;
        sysMonProc.running = true;
    }

    Rectangle {
        id: mainCard
        anchors.fill: parent
        radius: Theme.radiusCard
        color: "#f21e1e2e" // High opacity Catppuccin Mocha
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
                    color: Qt.rgba(PowerProfileService.profileColor.r, PowerProfileService.profileColor.g, PowerProfileService.profileColor.b, 0.18)

                    Text {
                        anchors.centerIn: parent
                        text: PowerProfileService.profileIcon
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 14
                        color: PowerProfileService.profileColor
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        text: "Performance & Hardware"
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: Theme.text
                    }

                    Text {
                        text: PowerProfileService.profileName + " • " + PowerProfileService.profileDescription
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        color: Theme.subtext
                        elide: Text.ElideRight
                        Layout.maximumWidth: 240
                    }
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

            // Profile Selection Row (3 Cards: Sparen, Balance, Leistung)
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                // 1. Energiesparen (power-saver)
                Rectangle {
                    id: saveCard
                    Layout.fillWidth: true
                    implicitHeight: 58
                    radius: 10
                    color: PowerProfileService.currentProfile === "power-saver" 
                        ? Qt.rgba(Theme.green.r, Theme.green.g, Theme.green.b, 0.16) 
                        : (saveMouse.containsMouse ? Theme.surface0 : "transparent")
                    border.color: PowerProfileService.currentProfile === "power-saver" ? Theme.green : Theme.surface1
                    border.width: PowerProfileService.currentProfile === "power-saver" ? 1.5 : 1

                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 120 } }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 3

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰾄"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 16
                            color: PowerProfileService.currentProfile === "power-saver" ? Theme.green : Theme.subtext
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Sparen"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: PowerProfileService.currentProfile === "power-saver" ? Theme.green : Theme.text
                        }
                    }

                    MouseArea {
                        id: saveMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PowerProfileService.setProfile("power-saver")
                    }
                }

                // 2. Ausbalanciert (balanced)
                Rectangle {
                    id: balCard
                    Layout.fillWidth: true
                    implicitHeight: 58
                    radius: 10
                    color: PowerProfileService.currentProfile === "balanced" 
                        ? Qt.rgba(Theme.blue.r, Theme.blue.g, Theme.blue.b, 0.16) 
                        : (balMouse.containsMouse ? Theme.surface0 : "transparent")
                    border.color: PowerProfileService.currentProfile === "balanced" ? Theme.blue : Theme.surface1
                    border.width: PowerProfileService.currentProfile === "balanced" ? 1.5 : 1

                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 120 } }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 3

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰾅"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 16
                            color: PowerProfileService.currentProfile === "balanced" ? Theme.blue : Theme.subtext
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Balance"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: PowerProfileService.currentProfile === "balanced" ? Theme.blue : Theme.text
                        }
                    }

                    MouseArea {
                        id: balMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PowerProfileService.setProfile("balanced")
                    }
                }

                // 3. Volle Leistung (performance)
                Rectangle {
                    id: perfCard
                    Layout.fillWidth: true
                    implicitHeight: 58
                    radius: 10
                    color: PowerProfileService.currentProfile === "performance" 
                        ? Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, 0.16) 
                        : (perfMouse.containsMouse ? Theme.surface0 : "transparent")
                    border.color: PowerProfileService.currentProfile === "performance" ? Theme.red : Theme.surface1
                    border.width: PowerProfileService.currentProfile === "performance" ? 1.5 : 1

                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 120 } }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 3

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰓅"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 16
                            color: PowerProfileService.currentProfile === "performance" ? Theme.red : Theme.subtext
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Leistung"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: PowerProfileService.currentProfile === "performance" ? Theme.red : Theme.text
                        }
                    }

                    MouseArea {
                        id: perfMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PowerProfileService.setProfile("performance")
                    }
                }
            }

            // Separator
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.surface0
            }

            // Hardware Stats Section Header
            Text {
                text: "Hardware Auslastung"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.weight: Font.Bold
                color: Theme.overlay
            }

            // CPU Stat Card
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 48
                radius: 10
                color: Theme.surface0

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 9
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true

                        RowLayout {
                            spacing: 6
                            Text {
                                text: "󰻠"
                                font.family: Theme.iconFontFamily
                                font.pixelSize: 13
                                color: Theme.blue
                            }
                            Text {
                                text: "Intel Core Ultra 7 265K"
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: Theme.text
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: popup.cpuTemp ? (popup.cpuPct + " • " + popup.cpuTemp) : popup.cpuPct
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: Theme.blue
                        }
                    }

                    // Progress bar
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 5
                        radius: 2.5
                        color: Theme.surface1

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: parent.width * popup.cpuFraction
                            radius: 2.5
                            color: Theme.blue

                            Behavior on width { NumberAnimation { duration: 200 } }
                        }
                    }
                }
            }

            // RAM Stat Card
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 48
                radius: 10
                color: Theme.surface0

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 9
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true

                        RowLayout {
                            spacing: 6
                            Text {
                                text: "󰍛"
                                font.family: Theme.iconFontFamily
                                font.pixelSize: 13
                                color: Theme.mauve
                            }
                            Text {
                                text: "Arbeitsspeicher"
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: Theme.text
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: popup.ramUsedGB + " / " + popup.ramTotalGB + " GB (" + popup.ramPct + ")"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: Theme.mauve
                        }
                    }

                    // Progress bar
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 5
                        radius: 2.5
                        color: Theme.surface1

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: parent.width * popup.ramFraction
                            radius: 2.5
                            color: Theme.mauve

                            Behavior on width { NumberAnimation { duration: 200 } }
                        }
                    }
                }
            }

            // GPU Stat Card (RTX 5080)
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 74
                radius: 10
                color: Theme.surface0

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 9
                    spacing: 5

                    RowLayout {
                        Layout.fillWidth: true

                        RowLayout {
                            spacing: 6
                            Text {
                                text: "󰢮"
                                font.family: Theme.iconFontFamily
                                font.pixelSize: 13
                                color: Theme.green
                            }
                            Text {
                                text: "NVIDIA GeForce RTX 5080"
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: Theme.text
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: popup.gpuTemp
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: Theme.green
                        }
                    }

                    // GPU Utilization Progress bar
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 5
                        radius: 2.5
                        color: Theme.surface1

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: parent.width * popup.gpuFraction
                            radius: 2.5
                            color: Theme.green

                            Behavior on width { NumberAnimation { duration: 200 } }
                        }
                    }

                    // Metrics Grid (Util, VRAM, Power)
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        // Util
                        RowLayout {
                            spacing: 4
                            Text { text: "Last:"; font.family: Theme.fontFamily; font.pixelSize: 10; color: Theme.subtext }
                            Text { text: popup.gpuPct; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.DemiBold; color: Theme.text }
                        }

                        // VRAM
                        RowLayout {
                            spacing: 4
                            Text { text: "VRAM:"; font.family: Theme.fontFamily; font.pixelSize: 10; color: Theme.subtext }
                            Text { text: popup.vramUsedGB + "/" + popup.vramTotalGB + " GB"; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.DemiBold; color: Theme.text }
                        }

                        Item { Layout.fillWidth: true }

                        // Power
                        RowLayout {
                            spacing: 4
                            Text { text: "Power:"; font.family: Theme.fontFamily; font.pixelSize: 10; color: Theme.subtext }
                            Text { text: popup.gpuPowerW; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.DemiBold; color: Theme.peach }
                        }
                    }
                }
            }

            // Footer Button: Systemmonitor
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 32
                radius: 8
                color: sysMonMouse.containsMouse ? Theme.surface0 : "transparent"

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
                        text: "KDE Systemmonitor öffnen"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Theme.subtext
                    }
                }

                MouseArea {
                    id: sysMonMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: popup.openSystemMonitor()
                }
            }
        }
    }
}
