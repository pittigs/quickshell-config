pragma Singleton
import QtQuick
import Quickshell.Io
import "../theme"

QtObject {
    id: root

    property string currentProfile: "balanced"

    readonly property string profileName: {
        if (currentProfile === "performance") return "Volle Leistung";
        if (currentProfile === "power-saver") return "Energiesparen";
        return "Ausbalanciert";
    }

    readonly property string profileIcon: {
        if (currentProfile === "performance") return "󰓅";
        if (currentProfile === "power-saver") return "󰾄";
        return "󰾅";
    }

    readonly property color profileColor: {
        if (currentProfile === "performance") return Theme.red;
        if (currentProfile === "power-saver") return Theme.green;
        return Theme.blue;
    }

    readonly property string profileDescription: {
        if (currentProfile === "performance") return "Maximaler Turbotakt, minimale Latenz für Gaming & Rendern";
        if (currentProfile === "power-saver") return "Geringer Stromverbrauch, leise Lüfter, sparsamer Takt";
        return "Automatische, dynamische Anpassung nach Bedarf";
    }

    // Process to apply profile
    property var setProc: Process {
        id: setProcess
        command: ["powerprofilesctl", "set", "balanced"]
    }

    function setProfile(name) {
        if (name !== "power-saver" && name !== "balanced" && name !== "performance") return;
        currentProfile = name;
        setProcess.command = ["powerprofilesctl", "set", name];
        setProcess.running = true;
    }

    function cycleNext() {
        if (currentProfile === "power-saver") setProfile("balanced");
        else if (currentProfile === "balanced") setProfile("performance");
        else setProfile("power-saver");
    }

    function cyclePrev() {
        if (currentProfile === "performance") setProfile("balanced");
        else if (currentProfile === "balanced") setProfile("power-saver");
        else setProfile("performance");
    }

    // Process to query current profile
    property var getProc: Process {
        id: getProcess
        command: ["powerprofilesctl", "get"]
        running: true

        stdout: StdioCollector {
            onTextChanged: {
                if (text && text.trim().length > 0) {
                    const prof = text.trim();
                    if (prof === "power-saver" || prof === "balanced" || prof === "performance") {
                        root.currentProfile = prof;
                    }
                }
            }
        }
    }

    // Refresh every 4 seconds
    property var pollTimer: Timer {
        interval: 4000
        running: true
        repeat: true
        onTriggered: {
            getProcess.running = true;
        }
    }
}
