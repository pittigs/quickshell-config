import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import "../theme"

Pill {
    id: root

    clickable: true
    implicitHeight: 34
    implicitWidth: layout.implicitWidth + 24
    active: audioPopup.visible

    property var parentWindow: null

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool hasAudio: Boolean(sink && sink.audio)
    readonly property bool isMuted: hasAudio ? sink.audio.muted : false
    readonly property real volume: hasAudio ? sink.audio.volume : 0.0
    readonly property int volumePercent: Math.round(root.volume * 100)

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    AudioQuickSelect {
        id: audioPopup
        anchorItem: root
        anchorWindow: root.parentWindow
    }

    readonly property string icon: {
        if (!root.hasAudio || root.isMuted || root.volumePercent === 0) return "󰝟"
        if (root.volumePercent > 60) return "󰕾"
        if (root.volumePercent > 25) return "󰖀"
        return "󰕿"
    }

    onClicked: {
        audioPopup.visible = !audioPopup.visible;
    }

    onRightClicked: {
        if (root.hasAudio) {
            root.sink.audio.muted = !root.sink.audio.muted;
        }
    }

    onWheelUp: {
        if (root.hasAudio) {
            root.sink.audio.volume = Math.min(1.5, root.sink.audio.volume + 0.03);
        }
    }

    onWheelDown: {
        if (root.hasAudio) {
            root.sink.audio.volume = Math.max(0.0, root.sink.audio.volume - 0.03);
        }
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: root.icon
            font.family: Theme.iconFontFamily
            font.pixelSize: 14
            color: {
                if (root.isMuted) return Theme.red
                if (root.hovered || audioPopup.visible) return Theme.mauve
                return Theme.blue
            }

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }

        Text {
            text: root.isMuted ? "Stumm" : (root.volumePercent + "%")
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.Medium
            color: root.isMuted ? Theme.overlay : Theme.text
        }

        Text {
            text: "󰅀"
            font.family: Theme.iconFontFamily
            font.pixelSize: 10
            color: audioPopup.visible ? Theme.mauve : Theme.overlay
            opacity: root.hovered || audioPopup.visible ? 1.0 : 0.6

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }
        }
    }
}
