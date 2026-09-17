import QtQuick
import QtQuick.Layouts
import Quickshell.Io
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

    property string cpuPercent: "..."
    property real cpuFraction: 0.0
    property string ramPercent: "..."
    property real ramFraction: 0.0
    property string ramUsedGB: "0.0"
    property string ramTotalGB: "64.0"

    property string gpuTemp: ""
    property string gpuPercent: ""
    property real gpuFraction: 0.0
    property string vramUsedGB: "0.0"
    property string vramTotalGB: "16.0"
    property string gpuPowerW: "0 W"
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

    PerformancePopup {
        id: perfPopup
        anchorItem: root
        anchorWindow: root.parentWindow

        cpuPct: root.cpuPercent
        cpuFraction: root.cpuFraction
        ramPct: root.ramPercent
        ramFraction: root.ramFraction
        ramUsedGB: root.ramUsedGB
        ramTotalGB: root.ramTotalGB
        gpuTemp: root.gpuTemp
        gpuPct: root.gpuPercent
        gpuFraction: root.gpuFraction
        vramUsedGB: root.vramUsedGB
        vramTotalGB: root.vramTotalGB
        gpuPowerW: root.gpuPowerW
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

    // Process to read CPU, RAM and RTX 5080 GPU stats
    Process {
        id: sysProc
        command: [
            "sh", "-c",
            "read -r cpu u n s i w irq sirq st g gn < /proc/stat; " +
            "idle1=$((i + w)); total1=$((u + n + s + i + w + irq + sirq + st)); " +
            "sleep 0.12; " +
            "read -r cpu u n s i w irq sirq st g gn < /proc/stat; " +
            "idle2=$((i + w)); total2=$((u + n + s + i + w + irq + sirq + st)); " +
            "cpu_pct=$(( (100 * ( (total2 - total1) - (idle2 - idle1) )) / (total2 - total1) )); " +
            "ram_info=$(free -m | awk '/Mem:/ { printf(\"%d:%d:%d\", ($3/$2)*100, $3, $2) }'); " +
            "gpu_info=$(nvidia-smi --query-gpu=temperature.gpu,utilization.gpu,memory.used,memory.total,power.draw --format=csv,noheader,nounits 2>/dev/null || echo '0,0,0,0,0'); " +
            "echo \"$cpu_pct|$ram_info|$gpu_info\""
        ]
        running: true

        stdout: StdioCollector {
            onTextChanged: {
                if (text && text.trim().length > 0) {
                    const sections = text.trim().split("|");
                    if (sections.length >= 3) {
                        // CPU
                        const cVal = parseInt(sections[0]) || 0;
                        root.cpuPercent = cVal + "%";
                        root.cpuFraction = Math.max(0, Math.min(1, cVal / 100));

                        // RAM
                        const rParts = sections[1].split(":");
                        if (rParts.length >= 3) {
                            const rPct = parseInt(rParts[0]) || 0;
                            const rUsed = parseInt(rParts[1]) || 0;
                            const rTot = parseInt(rParts[2]) || 1;
                            root.ramPercent = rPct + "%";
                            root.ramFraction = Math.max(0, Math.min(1, rPct / 100));
                            root.ramUsedGB = (rUsed / 1024).toFixed(1);
                            root.ramTotalGB = (rTot / 1024).toFixed(1);
                        }

                        // GPU
                        const gParts = sections[2].split(",");
                        if (gParts.length >= 5) {
                            const gTemp = gParts[0].trim();
                            const gUtil = parseInt(gParts[1].trim()) || 0;
                            const vUsed = parseInt(gParts[2].trim()) || 0;
                            const vTot = parseInt(gParts[3].trim()) || 1;
                            const gPow = parseFloat(gParts[4].trim()) || 0;

                            if (gTemp && gTemp !== "0") {
                                root.gpuTemp = gTemp + "°C";
                                root.gpuPercent = gUtil + "%";
                                root.gpuFraction = Math.max(0, Math.min(1, gUtil / 100));
                                root.vramUsedGB = (vUsed / 1024).toFixed(1);
                                root.vramTotalGB = (vTot / 1024).toFixed(1);
                                root.gpuPowerW = Math.round(gPow) + " W";
                            }
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
            sysProc.running = true;
        }
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
