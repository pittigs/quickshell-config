pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property int currentDesktop: 1
    property int desktopCount: 2
    property var desktops: [1, 2]

    property var queryProc: Process {
        id: queryProc
        command: [
            "sh", "-c",
            "curr=$(qdbus org.kde.KWin /KWin org.kde.KWin.currentDesktop 2>/dev/null || echo 1); " +
            "cnt=$(qdbus org.kde.KWin /VirtualDesktopManager org.kde.KWin.VirtualDesktopManager.count 2>/dev/null || echo 1); " +
            "echo \"$curr:$cnt\""
        ]
        running: true

        stdout: StdioCollector {
            onTextChanged: {
                if (!text || text.trim().length === 0) return;
                const parts = text.trim().split(":");
                if (parts.length >= 2) {
                    const c = parseInt(parts[0]) || 1;
                    const cnt = Math.max(1, parseInt(parts[1]) || 1);
                    root.currentDesktop = c;
                    root.desktopCount = cnt;

                    const list = [];
                    for (let i = 1; i <= cnt; i++) {
                        list.push(i);
                    }
                    root.desktops = list;
                }
            }
        }
    }

    property var pollTimer: Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            if (!queryProc.running) {
                queryProc.running = true;
            }
        }
    }

    property var execProc: Process {
        id: execProc
        command: ["sh", "-c", "true"]
    }

    function runCmd(cmd) {
        if (execProc.running) execProc.running = false;
        execProc.command = ["sh", "-c", cmd];
        execProc.running = true;
    }

    function switchTo(deskNum) {
        if (deskNum === root.currentDesktop) return;
        root.currentDesktop = deskNum;
        if (deskNum > root.desktopCount) {
            runCmd("qdbus org.kde.KWin /VirtualDesktopManager createDesktop " + (root.desktopCount) + " \"Desktop " + deskNum + "\" && qdbus org.kde.KWin /KWin setCurrentDesktop " + deskNum);
        } else {
            runCmd("qdbus org.kde.KWin /KWin setCurrentDesktop " + deskNum);
        }
        queryTimer.restart();
    }

    function next() {
        runCmd("qdbus org.kde.KWin /KWin org.kde.KWin.nextDesktop");
        queryTimer.restart();
    }

    function previous() {
        runCmd("qdbus org.kde.KWin /KWin org.kde.KWin.previousDesktop");
        queryTimer.restart();
    }

    function createNewDesktop() {
        const nextId = root.desktopCount + 1;
        runCmd("qdbus org.kde.KWin /VirtualDesktopManager createDesktop " + root.desktopCount + " \"Desktop " + nextId + "\" && qdbus org.kde.KWin /KWin setCurrentDesktop " + nextId);
        queryTimer.restart();
    }

    property var queryTimer: Timer {
        id: queryTimer
        interval: 150
        repeat: false
        onTriggered: {
            if (!queryProc.running) queryProc.running = true;
        }
    }
}
