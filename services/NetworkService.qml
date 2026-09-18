pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property string interfaceName: "enp129s0"
    property string localIp: "..."
    property string gateway: "..."
    property bool isOnline: false
    property bool isWifi: false
    property string interfaceIcon: isWifi ? "󰖩" : "󰛳"

    property real downBytesSec: 0
    property real upBytesSec: 0
    property string downSpeedStr: "0 B/s"
    property string upSpeedStr: "0 B/s"

    // Internal state for deltas
    property real _lastRx: 0
    property real _lastTx: 0
    property real _lastTime: 0

    function formatSpeed(bytesPerSec) {
        if (bytesPerSec < 1024) return Math.round(bytesPerSec) + " B/s";
        if (bytesPerSec < 1024 * 1024) return (bytesPerSec / 1024).toFixed(0) + " KB/s";
        return (bytesPerSec / (1024 * 1024)).toFixed(1) + " MB/s";
    }

    property var proc: Process {
        id: netProc
        command: [
            "sh", "-c",
            "dev=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i==\"dev\") print $(i+1)}'); " +
            "ip=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i==\"src\") print $(i+1)}'); " +
            "gw=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i==\"via\") print $(i+1)}'); " +
            "bytes=$(awk -v d=\"$dev:\" '$1==d {print $2 \":\" $10}' /proc/net/dev); " +
            "echo \"$dev|$ip|$gw|$bytes\""
        ]
        running: true

        stdout: StdioCollector {
            onTextChanged: {
                if (!text || text.trim().length === 0) return;
                const parts = text.trim().split("|");
                if (parts.length < 4) return;

                const dev = parts[0].trim();
                const ip = parts[1].trim();
                const gw = parts[2].trim();
                const byteParts = parts[3].trim().split(":");

                root.interfaceName = dev || "eth0";
                root.localIp = ip || "Nicht verbunden";
                root.gateway = gw || "Kein Gateway";
                root.isOnline = Boolean(ip && ip !== "");
                root.isWifi = dev.startsWith("wl");

                if (byteParts.length >= 2) {
                    const rx = parseFloat(byteParts[0]) || 0;
                    const tx = parseFloat(byteParts[1]) || 0;
                    const now = Date.now();

                    if (root._lastTime > 0 && now > root._lastTime && rx >= root._lastRx && tx >= root._lastTx) {
                        const dt = (now - root._lastTime) / 1000;
                        if (dt > 0.5) {
                            root.downBytesSec = (rx - root._lastRx) / dt;
                            root.upBytesSec = (tx - root._lastTx) / dt;
                            root.downSpeedStr = root.formatSpeed(root.downBytesSec);
                            root.upSpeedStr = root.formatSpeed(root.upBytesSec);
                        }
                    }
                    root._lastRx = rx;
                    root._lastTx = tx;
                    root._lastTime = now;
                }
            }
        }
    }

    property var pollTimer: Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (!netProc.running) {
                netProc.running = true;
            }
        }
    }
}
