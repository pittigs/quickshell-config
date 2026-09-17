import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.UPower
import "../theme"

Pill {
    id: root

    implicitHeight: 34
    implicitWidth: layout.implicitWidth + 24

    property string ramPercent: "..."
    readonly property var battery: UPower.displayDevice
    readonly property bool hasBattery: Boolean(battery && battery.isRechargeable)
    readonly property int batteryPercent: hasBattery ? Math.round(battery.percentage * 100) : 0
    readonly property bool isCharging: hasBattery ? (battery.state === UPowerDeviceState.Charging || battery.state === UPowerDeviceState.PendingCharge) : false

    readonly property string batteryIcon: {
        if (root.isCharging) return "󰂄"
        if (root.batteryPercent > 80) return "󰁹"
        if (root.batteryPercent > 50) return "󰁾"
        if (root.batteryPercent > 20) return "󰁼"
        return "󰁺"
    }

    // Process to read RAM percentage
    Process {
        id: ramProc
        command: ["sh", "-c", "free -m | awk '/Mem:/ { printf(\"%d\", ($3/$2)*100) }'"]
        running: true

        stdout: StdioCollector {
            onTextChanged: {
                if (text && text.trim().length > 0) {
                    root.ramPercent = text.trim() + "%"
                }
            }
        }
    }

    Timer {
        interval: 4000
        running: true
        repeat: true
        onTriggered: {
            ramProc.running = true
        }
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 8

        // RAM
        RowLayout {
            spacing: 5

            Text {
                text: "󰍛"
                font.family: Theme.fontFamily
                font.pixelSize: 13
                color: Theme.mauve
            }

            Text {
                text: root.ramPercent
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.weight: Font.Medium
                color: Theme.text
            }
        }

        // Battery (if available)
        Rectangle {
            visible: root.hasBattery
            implicitWidth: 1
            implicitHeight: 12
            color: Theme.surface1
        }

        RowLayout {
            visible: root.hasBattery
            spacing: 5

            Text {
                text: root.batteryIcon
                font.family: Theme.fontFamily
                font.pixelSize: 13
                color: root.isCharging ? Theme.green : (root.batteryPercent <= 20 ? Theme.red : Theme.peach)
            }

            Text {
                text: root.batteryPercent + "%"
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.weight: Font.Medium
                color: Theme.text
            }
        }
    }
}
