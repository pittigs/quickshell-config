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
    implicitWidth: 330
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
        if (wpctlProc.running) wpctlProc.running = false;
        wpctlProc.command = ["wpctl", "set-default", String(id)];
        wpctlProc.running = true;
    }

    function setDefaultSource(id) {
        if (wpctlProc.running) wpctlProc.running = false;
        wpctlProc.command = ["wpctl", "set-default", String(id)];
        wpctlProc.running = true;
    }

    function applyPreset(presetName) {
        if (presetName === "gaming") {
            for (let i = 0; i < sinks.length; i++) {
                const desc = (sinks[i].description || "").toLowerCase();
                if (desc.includes("inzone") || desc.includes("scarlett") || desc.includes("headphone")) {
                    setDefaultSink(sinks[i].id);
                    break;
                }
            }
            for (let i = 0; i < sources.length; i++) {
                const desc = (sources[i].description || "").toLowerCase();
                if (desc.includes("mic") || desc.includes("scarlett") || desc.includes("inzone")) {
                    setDefaultSource(sources[i].id);
                    break;
                }
            }
        } else if (presetName === "hifi") {
            for (let i = 0; i < sinks.length; i++) {
                const desc = (sinks[i].description || "").toLowerCase();
                if (desc.includes("onkyo") || desc.includes("receiver") || desc.includes("schlafzimmer")) {
                    setDefaultSink(sinks[i].id);
                    break;
                }
            }
        } else if (presetName === "desk") {
            for (let i = 0; i < sinks.length; i++) {
                const desc = (sinks[i].description || "").toLowerCase();
                if (desc.includes("gb203") || desc.includes("dell") || desc.includes("hdmi")) {
                    setDefaultSink(sinks[i].id);
                    break;
                }
            }
        }
    }

    // Active Sink (Audio Output)
    readonly property var activeSink: Pipewire.defaultAudioSink
    readonly property bool hasSinkAudio: Boolean(activeSink && activeSink.audio)
    readonly property real sinkVolume: hasSinkAudio ? activeSink.audio.volume : 0.0
    readonly property bool isSinkMuted: hasSinkAudio ? activeSink.audio.muted : false

    // Active Source (Microphone Input)
    readonly property var activeSource: Pipewire.defaultAudioSource
    readonly property bool hasSourceAudio: Boolean(activeSource && activeSource.audio)
    readonly property real sourceVolume: hasSourceAudio ? activeSource.audio.volume : 0.0
    readonly property bool isSourceMuted: hasSourceAudio ? activeSource.audio.muted : false

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

    // Filter available hardware sources (microphones), excluding internal stream splits
    readonly property var sources: {
        const list = [];
        const nodes = Pipewire.nodes.values;
        for (let i = 0; i < nodes.length; i++) {
            const n = nodes[i];
            if (!n.isSink && !n.isStream && n.audio) {
                if (n.name && (n.name.includes(".split") || n.name.includes(".hw_"))) {
                    continue;
                }
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
        let name = desc;
        if (name.includes("GB203")) {
            return "DELL S2721DGF (HDMI Audio)";
        }
        if (name.includes("800 Series Chipset") && name.includes("HDMI")) {
            return "ASUS PB277 (HDMI Audio)";
        }
        if (name.includes("800 Series Chipset")) {
            return "Onboard Audio (Mainboard)";
        }
        return name
            .replace(/\s*Analog Stereo\s*/i, "")
            .replace(/\s*Digital Stereo \(HDMI\)\s*/i, " (HDMI)")
            .replace(/\s*Headphones \/ Line 1-2\s*/i, " (Klinke)")
            .replace(/\s*Input 1 Mic\s*/i, " (Mikrofon 1)")
            .replace(/\s*Input 2 Inst\/Line\s*/i, " (Instrument 2)")
            .replace(/\s*Mono\s*/i, " (Headset-Mic)")
            .trim();
    }

    // Glassmorphic Card Container
    Rectangle {
        id: mainCard
        anchors.fill: parent
        implicitWidth: 330
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

            // Quick Scenario Presets Bar (Gaming, Hi-Fi, Desk)
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                // 1. Gaming Preset
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 28
                    radius: 8
                    color: gamingMouse.containsMouse ? Theme.surface1 : Theme.surface0

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            text: "󰊴"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 12
                            color: Theme.mauve
                        }

                        Text {
                            text: "Gaming"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: Theme.text
                        }
                    }

                    MouseArea {
                        id: gamingMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popup.applyPreset("gaming")
                    }
                }

                // 2. Hi-Fi / Receiver Preset
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 28
                    radius: 8
                    color: hifiMouse.containsMouse ? Theme.surface1 : Theme.surface0

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            text: "󰓃"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 12
                            color: Theme.peach
                        }

                        Text {
                            text: "Hi-Fi"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: Theme.text
                        }
                    }

                    MouseArea {
                        id: hifiMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popup.applyPreset("hifi")
                    }
                }

                // 3. Desk / Monitor Preset
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 28
                    radius: 8
                    color: deskMouse.containsMouse ? Theme.surface1 : Theme.surface0

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            text: "󰡁"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 12
                            color: Theme.blue
                        }

                        Text {
                            text: "Monitor"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: Theme.text
                        }
                    }

                    MouseArea {
                        id: deskMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popup.applyPreset("desk")
                    }
                }
            }

            // ==========================================
            // SECTION 1: OUTPUT (AUSGABE)
            // ==========================================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "󰕾"
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 12
                        color: Theme.blue
                    }

                    Text {
                        text: "Audio-Ausgabe (Lautstärke)"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: Theme.subtext
                    }
                }

                // Volume Control Bar Container
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 38
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

                // Sinks list
                Repeater {
                    model: popup.sinks

                    delegate: Rectangle {
                        id: sinkItem
                        required property var modelData

                        readonly property bool isSelected: Boolean(popup.activeSink && popup.activeSink.id === sinkItem.modelData.id)

                        Layout.fillWidth: true
                        implicitHeight: 32
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

            // ==========================================
            // SECTION 2: INPUT (MIKROFONE)
            // ==========================================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "󰍬"
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 12
                        color: Theme.green
                    }

                    Text {
                        text: "Eingabegeräte (Mikrofone & Pegel)"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: Theme.subtext
                    }
                }

                // Microphone Gain Control Bar Container
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 38
                    radius: 10
                    color: Theme.surface0

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 8

                        // Mic mute button icon
                        Rectangle {
                            implicitWidth: 24
                            implicitHeight: 24
                            radius: 12
                            color: micMuteMouse.containsMouse ? Theme.surface1 : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: (popup.isSourceMuted || popup.sourceVolume === 0) ? "󰍭" : "󰍬"
                                font.family: Theme.iconFontFamily
                                font.pixelSize: 14
                                color: popup.isSourceMuted ? Theme.red : Theme.green
                            }

                            MouseArea {
                                id: micMuteMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (popup.hasSourceAudio) {
                                        popup.activeSource.audio.muted = !popup.activeSource.audio.muted;
                                    }
                                }
                            }
                        }

                        // Interactive Mic Gain Slider Bar
                        Rectangle {
                            id: micSliderTrack
                            Layout.fillWidth: true
                            implicitHeight: 6
                            radius: 3
                            color: Theme.surface1

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: Math.max(0, Math.min(micSliderTrack.width, (popup.sourceVolume / 1.0) * micSliderTrack.width))
                                radius: 3
                                color: popup.isSourceMuted ? Theme.overlay : Theme.green
                            }

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -6
                                cursorShape: Qt.PointingHandCursor

                                function updateMicVolume(mouseX) {
                                    if (popup.hasSourceAudio) {
                                        const clampedX = Math.max(0, Math.min(micSliderTrack.width, mouseX - 6));
                                        const fraction = clampedX / micSliderTrack.width;
                                        popup.activeSource.audio.volume = Math.round(fraction * 1.0 * 100) / 100;
                                    }
                                }

                                onClicked: (mouse) => updateMicVolume(mouse.x)
                                onPositionChanged: (mouse) => {
                                    if (pressed) updateMicVolume(mouse.x);
                                }
                            }
                        }

                        // Percentage Text
                        Text {
                            text: popup.isSourceMuted ? "Stumm" : (Math.round(popup.sourceVolume * 100) + "%")
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: popup.isSourceMuted ? Theme.overlay : Theme.text
                            Layout.preferredWidth: 38
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }

                // Sources list
                Repeater {
                    model: popup.sources

                    delegate: Rectangle {
                        id: sourceItem
                        required property var modelData

                        readonly property bool isSelected: Boolean(popup.activeSource && popup.activeSource.id === sourceItem.modelData.id)

                        Layout.fillWidth: true
                        implicitHeight: 32
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
