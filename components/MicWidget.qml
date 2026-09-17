import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import "../theme"

Pill {
    id: root

    clickable: true
    implicitHeight: 34
    implicitWidth: layout.implicitWidth + 24

    readonly property var source: Pipewire.defaultAudioSource
    readonly property bool hasAudio: Boolean(source && source.audio)
    readonly property bool isMuted: hasAudio ? source.audio.muted : false
    readonly property real volume: hasAudio ? source.audio.volume : 0.0
    readonly property int volumePercent: Math.round(root.volume * 100)

    PwObjectTracker {
        objects: root.source ? [root.source] : []
    }

    readonly property string icon: (!root.hasAudio || root.isMuted) ? "󰍭" : "󰍬"

    onClicked: {
        if (root.hasAudio) {
            root.source.audio.muted = !root.source.audio.muted
        }
    }

    onWheelUp: {
        if (root.hasAudio) {
            root.source.audio.volume = Math.min(1.5, root.source.audio.volume + 0.03)
        }
    }

    onWheelDown: {
        if (root.hasAudio) {
            root.source.audio.volume = Math.max(0.0, root.source.audio.volume - 0.03)
        }
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 7

        Text {
            text: root.icon
            font.family: Theme.iconFontFamily
            font.pixelSize: 14
            color: {
                if (root.isMuted) return Theme.red
                if (root.hovered) return Theme.mauve
                return Theme.green
            }

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }

        Text {
            text: root.isMuted ? "Mute" : (root.volumePercent + "%")
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.Medium
            color: root.isMuted ? Theme.overlay : Theme.text
        }
    }
}
