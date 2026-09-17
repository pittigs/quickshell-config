import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
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
    implicitHeight: mainCard.implicitHeight

    // Track all nodes for live property updates
    PwObjectTracker {
        objects: Pipewire.nodes.values
    }

    Process {
        id: wpctlProc
        command: ["wpctl", "set-default", "0"]
    }

    function setDefaultSink(id) {
        wpctlProc.command = ["wpctl", "set-default", String(id)];
        wpctlProc.running = true;
    }

    function setDefaultSource(id) {
        wpctlProc.command = ["wpctl", "set-default", String(id)];
        wpctlProc.running = true;
    }

    readonly property var activeSink: Pipewire.defaultAudioSink
    readonly property bool hasSinkAudio: Boolean(activeSink && activeSink.audio)
    readonly property real sinkVolume: hasSinkAudio ? activeSink.audio.volume : 0.0
    readonly property bool isSinkMuted: hasSinkAudio ? activeSink.audio.muted : false

    readonly property var activeSource: Pipewire.defaultAudioSource

    // Filter available hardware sinks (audio outputs)
    readonly property var sinks: {
        const list = [];
        const nodes = Pipewire.nodes.values;
        for (let i = 0; i < nodes.length; i++) {
            const n = nodes[i];
            if (n.isSink && !n.isStream && n.audio) {
                list.push(n);
            }
        }
        return list;
    }

    // Filter available hardware sources (microphones)
    readonly property var sources: {
        const list = [];
        const nodes = Pipewire.nodes.values;
        for (let i = 0; i < nodes.length; i++) {
            const n = nodes[i];
            if (!n.isSink && !n.isStream && n.audio) {
                list.push(n);
            }
        }
        return list;
    }

    function getDeviceIcon(desc, isSink) {
        const d = (desc || "").toLowerCase();
        if (!isSink) {
            if (d.includes("headset") || d.includes("inzone")) return "󰋎";
            return "󰍬";
        }
        if (d.includes("headphone") || d.includes("headset") || d.includes("inzone")) return "󰋋";
        if (d.includes("hdmi") || d.includes("display") || d.includes("tv")) return "󰡁";
        if (d.includes("onkyo") || d.includes("receiver") || d.includes("speaker") || d.includes("schlafzimmer")) return "󰓃";
        if (d.includes("scarlett") || d.includes("focusrite")) return "󰗅";
        return "󰕾";
    }

    function cleanDeviceName(desc) {
        if (!desc) return "Unbekanntes Gerät";
        return desc
            .replace(/\s*Analog Stereo\s*/i, "")
            .replace(/\s*Digital Stereo \(HDMI\)\s*/i, " (HDMI)")
            .replace(/\s*Headphones \/ Line 1-2\s*/i, " (Klinke)")
            .trim();
    }

    // Glassmorphic Card Container
    Rectangle {
        id: mainCard
        anchors.fill: parent
        implicitWidth: 320
        implicitHeight: contentCol.implicitHeight + 24
        radius: Theme.radiusCard
        color: "#f21e1e2e"
        border.color: Theme.glassBorder
        border.width: 1

        // Drop shadow subtle inset border
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.color: "#15ffffff"
            border.width: 1
            anchors.margins: 1
        }

        ColumnLayout {
            id: contentCol
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 12
            spacing: 12

            // Top Header: Title & Close
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "󰓃"
                    font.family: Theme.iconFontFamily
                    font.pixelSize: 15
                    color: Theme.mauve
                }

                Text {
                    text: "Audio Quick Select"
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    color: Theme.text
                    Layout.fillWidth: true
                }

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

            // Volume Control Bar Container
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 40
                radius: 10
                color: Theme.surface0

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    // Mute button icon
                    Rectangle {
                        implicitWidth: 24
                        implicitHeight: 24
                        radius: 12
                        color: muteMouse.containsMouse ? Theme.surface1 : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: (popup.isSinkMuted || popup.sinkVolume === 0) ? "󰝟" : "󰕾"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 14
                            color: popup.isSinkMuted ? Theme.red : Theme.blue
                        }

                        MouseArea {
                            id: muteMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (popup.hasSinkAudio) {
                                    popup.activeSink.audio.muted = !popup.activeSink.audio.muted;
                                }
                            }
                        }
                    }

                    // Interactive Volume Slider Bar
                    Rectangle {
                        id: sliderTrack
                        Layout.fillWidth: true
                        implicitHeight: 6
                        radius: 3
                        color: Theme.surface1

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: Math.max(0, Math.min(sliderTrack.width, (popup.sinkVolume / 1.5) * sliderTrack.width))
                            radius: 3
                            color: popup.isSinkMuted ? Theme.overlay : Theme.blue
                        }

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            cursorShape: Qt.PointingHandCursor

                            function updateVolume(mouseX) {
                                if (popup.hasSinkAudio) {
                                    const clampedX = Math.max(0, Math.min(sliderTrack.width, mouseX - 6));
                                    const fraction = clampedX / sliderTrack.width;
                                    popup.activeSink.audio.volume = Math.round(fraction * 1.5 * 100) / 100;
                                }
                            }

                            onClicked: (mouse) => updateVolume(mouse.x)
                            onPositionChanged: (mouse) => {
                                if (pressed) updateVolume(mouse.x);
                            }
                        }
                    }

                    // Percentage Text
                    Text {
                        text: popup.isSinkMuted ? "Stumm" : (Math.round(popup.sinkVolume * 100) + "%")
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        color: popup.isSinkMuted ? Theme.overlay : Theme.text
                        Layout.preferredWidth: 38
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }

            // Divider Line
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: "#15ffffff"
            }

            // Section 1: Output Sinks (Ausgabegeräte)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "󰕾"
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 12
                        color: Theme.subtext
                    }

                    Text {
                        text: "Ausgabegeräte"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: Theme.subtext
                    }
                }

                Repeater {
                    model: popup.sinks

                    delegate: Rectangle {
                        id: sinkItem
                        required property var modelData

                        readonly property bool isSelected: Boolean(popup.activeSink && popup.activeSink.id === sinkItem.modelData.id)

                        Layout.fillWidth: true
                        implicitHeight: 34
                        radius: 8
                        color: {
                            if (isSelected) return Theme.surface0;
                            if (sinkMouse.containsMouse) return Theme.glassHover;
                            return "transparent";
                        }
                        border.color: isSelected ? Theme.blue : "transparent"
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 120 } }
                        Behavior on border.color { ColorAnimation { duration: 120 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 8

                            Text {
                                text: popup.getDeviceIcon(sinkItem.modelData.description, true)
                                font.family: Theme.iconFontFamily
                                font.pixelSize: 14
                                color: sinkItem.isSelected ? Theme.blue : Theme.subtext
                            }

                            Text {
                                text: popup.cleanDeviceName(sinkItem.modelData.description)
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.weight: sinkItem.isSelected ? Font.Bold : Font.Normal
                                color: sinkItem.isSelected ? Theme.text : Theme.subtext
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                visible: sinkItem.isSelected
                                text: "󰄬"
                                font.family: Theme.iconFontFamily
                                font.pixelSize: 12
                                color: Theme.green
                            }
                        }

                        MouseArea {
                            id: sinkMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                popup.setDefaultSink(sinkItem.modelData.id);
                            }
                        }
                    }
                }
            }

            // Divider Line
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: "#15ffffff"
            }

            // Section 2: Input Sources (Eingabegeräte / Mikrofone)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "󰍬"
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 12
                        color: Theme.subtext
                    }

                    Text {
                        text: "Eingabegeräte (Mikrofone)"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: Theme.subtext
                    }
                }

                Repeater {
                    model: popup.sources

                    delegate: Rectangle {
                        id: sourceItem
                        required property var modelData

                        readonly property bool isSelected: Boolean(popup.activeSource && popup.activeSource.id === sourceItem.modelData.id)

                        Layout.fillWidth: true
                        implicitHeight: 34
                        radius: 8
                        color: {
                            if (isSelected) return Theme.surface0;
                            if (sourceMouse.containsMouse) return Theme.glassHover;
                            return "transparent";
                        }
                        border.color: isSelected ? Theme.green : "transparent"
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 120 } }
                        Behavior on border.color { ColorAnimation { duration: 120 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 8

                            Text {
                                text: popup.getDeviceIcon(sourceItem.modelData.description, false)
                                font.family: Theme.iconFontFamily
                                font.pixelSize: 14
                                color: sourceItem.isSelected ? Theme.green : Theme.subtext
                            }

                            Text {
                                text: popup.cleanDeviceName(sourceItem.modelData.description)
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.weight: sourceItem.isSelected ? Font.Bold : Font.Normal
                                color: sourceItem.isSelected ? Theme.text : Theme.subtext
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                visible: sourceItem.isSelected
                                text: "󰄬"
                                font.family: Theme.iconFontFamily
                                font.pixelSize: 12
                                color: Theme.green
                            }
                        }

                        MouseArea {
                            id: sourceMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                popup.setDefaultSource(sourceItem.modelData.id);
                            }
                        }
                    }
                }
            }
        }
    }
}
