import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import "../theme"
import "../services"

Pill {
    id: root

    property var parentWindow: null

    clickable: true
    implicitHeight: 34
    implicitWidth: layout.implicitWidth + 24
    active: perfPopup.visible

    // Hardware stats mapped directly from central SysInfoService
    readonly property string cpuPercent: SysInfoService.cpuPercent
    readonly property real cpuFraction: SysInfoService.cpuFraction
    readonly property string cpuTemp: SysInfoService.cpuTemp
    readonly property string ramPercent: SysInfoService.ramPercent
    readonly property real ramFraction: SysInfoService.ramFraction
    readonly property string ramUsedGB: SysInfoService.ramUsedGB
    readonly property string ramTotalGB: SysInfoService.ramTotalGB

    readonly property string gpuTemp: SysInfoService.gpuTemp
    readonly property string gpuPercent: SysInfoService.gpuPercent
    readonly property real gpuFraction: SysInfoService.gpuFraction
    readonly property string vramUsedGB: SysInfoService.vramUsedGB
    readonly property string vramTotalGB: SysInfoService.vramTotalGB
    readonly property string gpuPowerW: SysInfoService.gpuPowerW
    readonly property bool hasGpu: SysInfoService.hasGpu

    readonly property var battery: UPower.displayDevice
    readonly property bool hasBattery: Boolean(battery && (battery.isLaptopBattery || battery.isPresent) && battery.type === UPowerDeviceType.Battery)
    readonly property int batteryPercent: hasBattery ? Math.round(battery.percentage <= 1.0 ? battery.percentage * 100 : battery.percentage) : 0
    readonly property bool isCharging: hasBattery ? (battery.state === UPowerDeviceState.Charging || battery.state === UPowerDeviceState.PendingCharge) : false

    readonly property string batteryIcon: {
        if (root.isCharging) return "󰂄"
        if (root.batteryPercent > 80) return "󰁹"
        if (root.batteryPercent > 50) return "󰁾"
        if (root.batteryPercent > 20) return "󰁼"
        return "󰁺"
    }

    PerformancePopup {
        id: perfPopup
        anchorItem: root
        anchorWindow: root.parentWindow
    }

    onClicked: {
        perfPopup.visible = !perfPopup.visible;
    }

    onRightClicked: {
        PowerProfileService.cycleNext();
    }

    onWheelUp: {
        PowerProfileService.cycleNext();
    }

    onWheelDown: {
        PowerProfileService.cyclePrev();
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 8

        // Active Power Profile Badge
        RowLayout {
            spacing: 4

            Text {
                text: PowerProfileService.profileIcon
                font.family: Theme.iconFontFamily
                font.pixelSize: 13
                color: PowerProfileService.profileColor

                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }

        Rectangle {
            implicitWidth: 1
            implicitHeight: 12
            color: Theme.surface1
        }

        // CPU (Load & Package Temperature)
        RowLayout {
            spacing: 5

            Text {
                text: "󰻠"
                font.family: Theme.iconFontFamily
                font.pixelSize: 13
                color: Theme.blue
            }

            Text {
                text: root.cpuTemp ? (root.cpuPercent + " • " + root.cpuTemp) : root.cpuPercent
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.weight: Font.Medium
                color: Theme.text
            }
        }

        Rectangle {
            implicitWidth: 1
            implicitHeight: 12
            color: Theme.surface1
        }

        // RAM
        RowLayout {
            spacing: 5

            Text {
                text: "󰍛"
                font.family: Theme.iconFontFamily
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

        // GPU (NVIDIA RTX 5080)
        Rectangle {
            visible: root.hasGpu
            implicitWidth: 1
            implicitHeight: 12
            color: Theme.surface1
        }

        RowLayout {
            visible: root.hasGpu
            spacing: 5

            Text {
                text: "󰢮"
                font.family: Theme.iconFontFamily
                font.pixelSize: 13
                color: Theme.green
            }

            Text {
                text: root.gpuTemp
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.weight: Font.Medium
                color: Theme.text
            }
        }

        // Battery (if available on laptops)
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
                font.family: Theme.iconFontFamily
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
