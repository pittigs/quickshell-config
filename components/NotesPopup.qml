import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
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
    implicitWidth: 320
    implicitHeight: 280

    property bool isLoaded: false
    property bool copiedFeedback: false

    readonly property string notesFilePath: (Quickshell.env("HOME") || "/home/bas_pit") + "/.config/quickshell/scratchpad_notes.txt"

    Process {
        id: loadProc
        command: ["sh", "-c", "cat \"$HOME/.config/quickshell/scratchpad_notes.txt\" 2>/dev/null || touch \"$HOME/.config/quickshell/scratchpad_notes.txt\""]
        running: true

        stdout: StdioCollector {
            onTextChanged: {
                if (text && !popup.isLoaded) {
                    noteArea.text = text;
                    popup.isLoaded = true;
                }
            }
        }
    }

    Process {
        id: saveProc
        command: ["sh", "-c", "true"]
    }

    function saveNotes() {
        if (!popup.isLoaded) return;
        const b64 = Qt.btoa(encodeURIComponent(noteArea.text));
        saveProc.command = [
            "python3", "-c",
            "import sys, base64, urllib.parse; open(sys.argv[1], 'w', encoding='utf-8').write(urllib.parse.unquote(base64.b64decode(sys.argv[2]).decode('utf-8')))",
            popup.notesFilePath,
            b64
        ];
        saveProc.running = true;
    }

    Timer {
        id: debounceTimer
        interval: 600
        repeat: false
        onTriggered: popup.saveNotes()
    }

    function copyAll() {
        Quickshell.clipboardText = noteArea.text;
        copiedFeedback = true;
        copyTimer.restart();
    }

    Timer {
        id: copyTimer
        interval: 1800
        onTriggered: popup.copiedFeedback = false
    }

    function clearNotes() {
        noteArea.text = "";
        popup.saveNotes();
    }

    Rectangle {
        id: mainCard
        anchors.fill: parent
        radius: Theme.radiusCard
        color: "#f21e1e2e"
        border.color: Theme.glassBorder
        border.width: 1
        clip: true

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
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    implicitWidth: 26
                    implicitHeight: 26
                    radius: 13
                    color: Qt.rgba(Theme.yellow.r, Theme.yellow.g, Theme.yellow.b, 0.15)

                    Text {
                        anchors.centerIn: parent
                        text: "󰏫"
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 14
                        color: Theme.yellow
                    }
                }

                Text {
                    text: "Quick Notes"
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    color: Theme.text
                    Layout.fillWidth: true
                }

                // Copy All Button
                Rectangle {
                    implicitWidth: copyLabel.implicitWidth + 12
                    implicitHeight: 22
                    radius: 11
                    color: copyMouse.containsMouse ? Theme.surface1 : "transparent"
                    border.color: Theme.surface1
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text: popup.copiedFeedback ? "󰄬" : "󰅍"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 10
                            color: popup.copiedFeedback ? Theme.green : Theme.yellow
                        }

                        Text {
                            id: copyLabel
                            text: popup.copiedFeedback ? "Kopiert!" : "Kopieren"
                            font.family: Theme.fontFamily
                            font.pixelSize: 9
                            color: popup.copiedFeedback ? Theme.green : Theme.text
                        }
                    }

                    MouseArea {
                        id: copyMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popup.copyAll()
                    }
                }

                // Clear Button
                Rectangle {
                    implicitWidth: 22
                    implicitHeight: 22
                    radius: 11
                    color: clearMouse.containsMouse ? Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, 0.2) : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "󰆴"
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 12
                        color: clearMouse.containsMouse ? Theme.red : Theme.subtext
                    }

                    MouseArea {
                        id: clearMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popup.clearNotes()
                    }
                }

                // Close Button
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

            // Note Text Area Card
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 10
                color: Theme.surface0
                border.color: noteArea.activeFocus ? Theme.blue : Theme.surface1
                border.width: 1

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 8
                    clip: true

                    TextArea {
                        id: noteArea
                        placeholderText: "Schreibe hier eine schnelle Notiz oder Todo-Liste..."
                        placeholderTextColor: Theme.overlay
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.text
                        wrapMode: TextEdit.Wrap
                        selectByMouse: true
                        background: null

                        onTextChanged: {
                            if (popup.isLoaded) {
                                debounceTimer.restart();
                            }
                        }
                    }
                }
            }

            // Footer
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Auto-Save aktiv"
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    color: Theme.green
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: String(noteArea.text.length) + " Zeichen"
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    color: Theme.subtext
                }
            }
        }
    }
}
