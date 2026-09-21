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
    implicitWidth: 300
    implicitHeight: mainCard.implicitHeight

    property bool nightLightActive: false
    property bool dndActive: false
    property bool bluetoothActive: true
    property int brightnessPercent: 100
    property int brightnessMaxVal: 10000

    onVisibleChanged: {
        if (visible && !queryStateProc.running) {
            queryStateProc.running = true;
        }
    }

    Process {
        id: queryStateProc
        command: [
            "sh", "-c",
            "nl=$(qdbus org.kde.KWin.NightLight /org/kde/KWin/NightLight org.kde.KWin.NightLight.running 2>/dev/null || echo false); " +
            "dnd=$(kreadconfig6 --file plasmanotifyrc --group DoNotDisturb --key notificationSoundMuted 2>/dev/null || echo false); " +
            "bt=$(bluetoothctl show 2>/dev/null | grep -q 'Powered: yes' && echo true || echo false); " +
            "br=$(qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/BrightnessControl org.kde.Solid.PowerManagement.Actions.BrightnessControl.brightness 2>/dev/null || echo 10000); " +
            "brmax=$(qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/BrightnessControl org.kde.Solid.PowerManagement.Actions.BrightnessControl.brightnessMax 2>/dev/null || echo 10000); " +
            "echo \"$nl|$dnd|$bt|$br|$brmax\""
        ]
        running: true

        stdout: StdioCollector {
            onTextChanged: {
                if (!text || text.trim().length === 0) return;
                const parts = text.trim().split("|");
                if (parts.length >= 5) {
                    popup.nightLightActive = (parts[0].trim() === "true");
                    popup.dndActive = (parts[1].trim() === "true");
                    popup.bluetoothActive = (parts[2].trim() === "true");
                    const curBr = parseInt(parts[3]) || 10000;
                    const maxBr = Math.max(1, parseInt(parts[4]) || 10000);
                    popup.brightnessMaxVal = maxBr;
                    popup.brightnessPercent = Math.round((curBr / maxBr) * 100);
                }
            }
        }
    }

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

    function toggleBluetooth() {
        bluetoothActive = !bluetoothActive;
        const cmd = bluetoothActive ? "bluetoothctl power on" : "bluetoothctl power off";
        runCmd(cmd);
    }

    function setBrightness(pct) {
        pct = Math.max(5, Math.min(100, pct));
        popup.brightnessPercent = pct;
        const raw = Math.round((pct / 100) * popup.brightnessMaxVal);
        runCmd("qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/BrightnessControl org.kde.Solid.PowerManagement.Actions.BrightnessControl.setBrightnessSilent " + raw);
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

        // Scale & Opacity smooth entrance animation
        scale: popup.visible ? 1.0 : 0.95
        opacity: popup.visible ? 1.0 : 0.0
        Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

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

                // 1. Bluetooth Toggle
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 52
                    radius: 10
                    color: popup.bluetoothActive ? Qt.rgba(Theme.blue.r, Theme.blue.g, Theme.blue.b, 0.18) : Theme.surface0
                    border.color: popup.bluetoothActive ? Theme.blue : "transparent"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        Text {
                            text: popup.bluetoothActive ? "󰂯" : "󰂲"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 18
                            color: popup.bluetoothActive ? Theme.blue : Theme.subtext
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                text: "Bluetooth"
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: popup.bluetoothActive ? Theme.blue : Theme.text
                            }

                            Text {
                                text: popup.bluetoothActive ? "Aktiviert" : "Aus"
                                font.family: Theme.fontFamily
                                font.pixelSize: 9
                                color: Theme.subtext
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popup.toggleBluetooth()
                    }
                }

                // 2. Nachtmodus (Night Light)
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

                // 3. Nicht stören (DND)
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

                // 4. Screenshot Bereich
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
                            color: Theme.green
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                text: "Screenshot"
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: Theme.text
                            }

                            Text {
                                text: "Bereich wählen"
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
            }

            // Brightness Slider Card
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 46
                radius: 10
                color: Theme.surface0

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    Text {
                        text: "󰃟"
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 16
                        color: Theme.yellow
                    }

                    // Interactive Brightness Slider Track
                    Item {
                        Layout.fillWidth: true
                        implicitHeight: 16

                        Rectangle {
                            id: brTrack
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            height: 6
                            radius: 3
                            color: Theme.surface1

                            Rectangle {
                                height: parent.height
                                radius: parent.radius
                                color: Theme.yellow
                                width: Math.max(4, parent.width * (popup.brightnessPercent / 100))
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: (mouse) => {
                                const frac = Math.max(0.05, Math.min(1.0, mouse.x / width));
                                popup.setBrightness(Math.round(frac * 100));
                            }
                            onPositionChanged: (mouse) => {
                                if (pressed) {
                                    const frac = Math.max(0.05, Math.min(1.0, mouse.x / width));
                                    popup.setBrightness(Math.round(frac * 100));
                                }
                            }
                        }
                    }

                    Text {
                        text: popup.brightnessPercent + "%"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: Theme.text
                        Layout.preferredWidth: 32
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

                // Bluetooth Settings
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 30
                    radius: 8
                    color: btSetMouse.containsMouse ? Theme.surface0 : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        Text {
                            text: "󰂯"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 13
                            color: Theme.blue
                        }

                        Text {
                            text: "Bluetooth-Einstellungen"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            color: Theme.text
                            Layout.fillWidth: true
                        }
                    }

                    MouseArea {
                        id: btSetMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            popup.visible = false;
                            popup.runCmd("plasma-open-settings kcm_bluetooth");
                        }
                    }
                }

                // KDE System Settings
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 30
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
                    implicitHeight: 30
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
