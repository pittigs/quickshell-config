pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    // CPU telemetry
    property string cpuPercent: "..."
    property real cpuFraction: 0.0
    property string cpuTemp: ""

    // RAM telemetry
    property string ramPercent: "..."
    property real ramFraction: 0.0
    property string ramUsedGB: "0.0"
    property string ramTotalGB: "64.0"

    // GPU telemetry (NVIDIA GeForce RTX 5080)
    property string gpuTemp: ""
    property string gpuPercent: ""
    property real gpuFraction: 0.0
    property string vramUsedGB: "0.0"
    property string vramTotalGB: "16.0"
    property string gpuPowerW: "0 W"
    readonly property bool hasGpu: gpuTemp !== "" && gpuTemp !== "0°C"

    // Internal state for CPU delta calculations
    property real _lastIdle: 0
    property real _lastTotal: 0

    // Dynamic polling mode: 1.5s when active/popup open, 5s when idle on desktop
    property bool fastPolling: false
    onFastPollingChanged: {
        if (fastPolling && !sysProc.running) {
            sysProc.running = true;
        }
    }

    // Hardware Telemetry Polling Process
    property var proc: Process {
        id: sysProc
        command: [
            "sh", "-c",
            "read -r cpu u n s i w irq sirq st g gn < /proc/stat; " +
            "cpu_stat=\"$((i + w)):$((u + n + s + i + w + irq + sirq + st))\"; " +
            "cpu_temp=\"\"; " +
            "if [ -f /sys/class/hwmon/hwmon5/temp1_input ] && [ \"$(cat /sys/class/hwmon/hwmon5/name 2>/dev/null)\" = \"coretemp\" ]; then " +
            "  t=$(cat /sys/class/hwmon/hwmon5/temp1_input 2>/dev/null); " +
            "  if [ -n \"$t\" ]; then cpu_temp=\"$(( t / 1000 ))°C\"; fi; " +
            "else " +
            "  for h in /sys/class/hwmon/hwmon*; do " +
            "    if [ -f \"$h/name\" ] && [ \"$(cat \"$h/name\" 2>/dev/null)\" = \"coretemp\" ]; then " +
            "      t=$(cat \"$h/temp1_input\" 2>/dev/null); " +
            "      if [ -n \"$t\" ]; then cpu_temp=\"$(( t / 1000 ))°C\"; break; fi; " +
            "    fi; " +
            "  done; " +
            "fi; " +
            "ram_info=$(free -m | awk '/Mem:/ { printf(\"%d:%d:%d\", ($3/$2)*100, $3, $2) }'); " +
            "gpu_info=$(nvidia-smi --query-gpu=temperature.gpu,utilization.gpu,memory.used,memory.total,power.draw --format=csv,noheader,nounits 2>/dev/null || echo '0,0,0,0,0'); " +
            "echo \"$cpu_stat|$cpu_temp|$ram_info|$gpu_info\""
        ]
        running: true

        stdout: StdioCollector {
            onTextChanged: {
                if (!text || text.trim().length === 0) return;
                const sections = text.trim().split("|");
                if (sections.length < 4) return;

                // 1. CPU
                const cpuParts = sections[0].split(":");
                if (cpuParts.length >= 2) {
                    const idle = parseInt(cpuParts[0]) || 0;
                    const total = parseInt(cpuParts[1]) || 0;
                    if (root._lastTotal > 0 && total > root._lastTotal) {
                        const dTotal = total - root._lastTotal;
                        const dIdle = idle - root._lastIdle;
                        const pct = Math.max(0, Math.min(100, Math.round((100 * (dTotal - dIdle)) / dTotal)));
                        root.cpuPercent = pct + "%";
                        root.cpuFraction = pct / 100;
                    } else if (root.cpuPercent === "...") {
                        root.cpuPercent = "0%";
                        root.cpuFraction = 0.0;
                    }
                    root._lastIdle = idle;
                    root._lastTotal = total;
                }

                // 2. CPU Temp
                const temp = sections[1].trim();
                if (temp) {
                    root.cpuTemp = temp;
                }

                // 3. RAM
                const ramParts = sections[2].split(":");
                if (ramParts.length >= 3) {
                    const rPct = parseInt(ramParts[0]) || 0;
                    const rUsed = parseInt(ramParts[1]) || 0;
                    const rTot = parseInt(ramParts[2]) || 1;
                    root.ramPercent = rPct + "%";
                    root.ramFraction = Math.max(0, Math.min(1, rPct / 100));
                    root.ramUsedGB = (rUsed / 1024).toFixed(1);
                    root.ramTotalGB = (rTot / 1024).toFixed(1);
                }

                // 4. GPU (NVIDIA RTX 5080)
                const gpuParts = sections[3].split(",");
                if (gpuParts.length >= 5) {
                    const gTemp = gpuParts[0].trim();
                    const gUtil = parseInt(gpuParts[1].trim()) || 0;
                    const vUsed = parseInt(gpuParts[2].trim()) || 0;
                    const vTot = parseInt(gpuParts[3].trim()) || 1;
                    const gPow = parseFloat(gpuParts[4].trim()) || 0;

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

    // Refresh dynamically (1.5s when popup open, 5s on idle desktop)
    property var pollTimer: Timer {
        interval: root.fastPolling ? 1500 : 5000
        running: true
        repeat: true
        onTriggered: {
            if (!sysProc.running) {
                sysProc.running = true;
            }
        }
    }
}
