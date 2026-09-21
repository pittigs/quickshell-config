pragma Singleton
import QtQuick
import Quickshell.Io
import "../theme"

QtObject {
    id: root

    readonly property int modeFocus: 0
    readonly property int modeShortBreak: 1
    readonly property int modeLongBreak: 2

    property int currentMode: modeFocus
    property int focusDuration: 25 * 60       // 25 minutes
    property int shortBreakDuration: 5 * 60    // 5 minutes
    property int longBreakDuration: 15 * 60   // 15 minutes

    property int timeRemaining: focusDuration
    property bool isRunning: false
    property int completedPomodoros: 0

    readonly property string formattedTime: {
        const m = Math.floor(timeRemaining / 60);
        const s = timeRemaining % 60;
        return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s;
    }

    readonly property string modeName: {
        if (currentMode === modeFocus) return "Fokus";
        if (currentMode === modeShortBreak) return "Kurze Pause";
        return "Lange Pause";
    }

    readonly property color modeColor: {
        if (currentMode === modeFocus) return Theme.red;
        if (currentMode === modeShortBreak) return Theme.green;
        return Theme.blue;
    }

    readonly property string modeIcon: {
        if (currentMode === modeFocus) return "󰄉";
        if (currentMode === modeShortBreak) return "󰔟";
        return "󰒲";
    }

    readonly property real progress: {
        let total = focusDuration;
        if (currentMode === modeShortBreak) total = shortBreakDuration;
        else if (currentMode === modeLongBreak) total = longBreakDuration;
        if (total <= 0) return 0;
        return Math.max(0, Math.min(1, 1 - (timeRemaining / total)));
    }

    function getDurationForMode(mode) {
        if (mode === modeFocus) return focusDuration;
        if (mode === modeShortBreak) return shortBreakDuration;
        return longBreakDuration;
    }

    function setMode(mode) {
        currentMode = mode;
        isRunning = false;
        timeRemaining = getDurationForMode(mode);
    }

    function start() {
        if (timeRemaining <= 0) {
            timeRemaining = getDurationForMode(currentMode);
        }
        isRunning = true;
    }

    function pause() {
        isRunning = false;
    }

    function toggle() {
        if (isRunning) pause();
        else start();
    }

    function reset() {
        isRunning = false;
        timeRemaining = getDurationForMode(currentMode);
    }

    function skip() {
        isRunning = false;
        finishSession(false);
    }

    // Process to send notification and alert sound
    property var alertProc: Process {
        id: alertProcess
        command: ["sh", "-c", "true"]
    }

    function triggerAlert(title, message) {
        if (alertProcess.running) alertProcess.running = false;
        const safeTitle = title.replace(/'/g, "");
        const safeMsg = message.replace(/'/g, "");
        const cmd = "notify-send -a 'Pomodoro' -i 'alarm-symbolic' '" + safeTitle + "' '" + safeMsg + "'; " +
                    "canberra-gtk-play -i complete 2>/dev/null || paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null || true";
        alertProcess.command = ["sh", "-c", cmd];
        alertProcess.running = true;
    }

    function finishSession(isNaturalFinish) {
        if (currentMode === modeFocus) {
            if (isNaturalFinish) {
                completedPomodoros++;
            }
            const isLongBreak = (completedPomodoros > 0 && completedPomodoros % 4 === 0);
            const nextMode = isLongBreak ? modeLongBreak : modeShortBreak;
            if (isNaturalFinish) {
                triggerAlert(
                    "Fokus-Session beendet! 🎉",
                    isLongBreak ? "Großartige Arbeit! Zeit für eine lange Pause (15 Min)." : "Gute Arbeit! Zeit für eine kurze Pause (5 Min)."
                );
            }
            setMode(nextMode);
        } else {
            if (isNaturalFinish) {
                triggerAlert(
                    "Pause vorbei! ☕",
                    "Bereit für den nächsten Fokus-Block? (25 Min)"
                );
            }
            setMode(modeFocus);
        }
    }

    // Central countdown timer
    property var timer: Timer {
        interval: 1000
        running: root.isRunning
        repeat: true
        onTriggered: {
            if (root.timeRemaining > 1) {
                root.timeRemaining--;
            } else {
                root.timeRemaining = 0;
                root.isRunning = false;
                root.finishSession(true);
            }
        }
    }
}
