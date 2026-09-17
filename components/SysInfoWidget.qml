import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.UPower
import "../theme"

Pill {
    id: root

    implicitHeight: 34
    implicitWidth: layout.implicitWidth + 24

    property string cpuPercent: "..."
    property string ramPercent: "..."
    property string gpuTemp: ""
    property string gpuPercent: ""
    readonly property bool hasGpu: gpuTemp !== "" && gpuTemp !== "0°C"

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

    // Process to read CPU, RAM and RTX 5080 GPU stats
    Process {
        id: sysProc
        command: [
            "sh", "-c",
            "read -r cpu u n s i w irq sirq st g gn < /proc/stat; " +
            "idle1=$((i + w)); total1=$((u + n + s + i + w + irq + sirq + st)); " +
            "sleep 0.25; " +
            "read -r cpu u n s i w irq sirq st g gn < /proc/stat; " +
            "idle2=$((i + w)); total2=$((u + n + s + i + w + irq + sirq + st)); " +
            "cpu_pct=$(( (100 * ( (total2 - total1) - (idle2 - idle1) )) / (total2 - total1) )); " +
            "ram_pct=$(free -m | awk '/Mem:/ { printf(\"%d\", ($3/$2)*100) }'); " +
            "gpu_info=$(nvidia-smi --query-gpu=temperature.gpu,utilization.gpu --format=csv,noheader,nounits 2>/dev/null || echo '0, 0'); " +
            "gpu_temp=$(echo \"$gpu_info\" | cut -d, -f1 | tr -d ' '); " +
            "gpu_util=$(echo \"$gpu_info\" | cut -d, -f2 | tr -d ' '); " +
            "echo \"$cpu_pct:$ram_pct:$gpu_temp:$gpu_util\""
        ]
        running: true

        stdout: StdioCollector {
            onTextChanged: {
                if (text && text.trim().length > 0) {
                    const parts = text.trim().split(":");
                    if (parts.length >= 4) {
                        root.cpuPercent = parts[0] + "%"
                        root.ramPercent = parts[1] + "%"
                        if (parts[2] && parts[2] !== "0") {
                            root.gpuTemp = parts[2] + "°C"
                            root.gpuPercent = parts[3] + "%"
                        }
                    }
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            sysProc.running = true
        }
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 9

        // CPU
        RowLayout {
            spacing: 5

            Text {
                text: "󰻠"
                font.family: Theme.iconFontFamily
                font.pixelSize: 13
                color: Theme.blue
            }

            Text {
                text: root.cpuPercent
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
