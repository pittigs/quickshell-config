import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Mpris
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

    // Player selection
    property int selectedPlayerIndex: 0

    readonly property var players: Mpris.players.values

    readonly property var activePlayer: {
        if (!players || players.length === 0) return null;
        if (selectedPlayerIndex >= 0 && selectedPlayerIndex < players.length) {
            return players[selectedPlayerIndex];
        }
        return players[0];
    }

    readonly property bool isPlaying: Boolean(activePlayer && activePlayer.playbackState === MprisPlaybackState.Playing)
    readonly property string title: (activePlayer && activePlayer.trackTitle) ? activePlayer.trackTitle : "Kein Titel"
    readonly property string artist: (activePlayer && activePlayer.trackArtist) ? activePlayer.trackArtist : "Unbekannter Künstler"
    readonly property string album: (activePlayer && activePlayer.trackAlbum) ? activePlayer.trackAlbum : ""
    readonly property string artUrl: (activePlayer && activePlayer.trackArtUrl) ? activePlayer.trackArtUrl : ""

    function formatTime(seconds) {
        if (!seconds || isNaN(seconds) || seconds < 0) return "0:00";
        const m = Math.floor(seconds / 60);
        const s = Math.floor(seconds % 60);
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    Rectangle {
        id: mainCard
        anchors.fill: parent
        radius: Theme.radiusCard
        color: "#f21e1e2e"
        border.color: Theme.glassBorder
        border.width: 1
        clip: true

        implicitHeight: contentCol.implicitHeight + 24

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
            id: contentCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 14
            spacing: 12

            // Header: Icon + Title + Player Switcher
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    implicitWidth: 26
                    implicitHeight: 26
                    radius: 13
                    color: Qt.rgba(Theme.green.r, Theme.green.g, Theme.green.b, 0.15)

                    Text {
                        anchors.centerIn: parent
                        text: "󰎈"
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 14
                        color: Theme.green
                    }
                }

                Text {
                    text: "Medien"
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    color: Theme.text
                    Layout.fillWidth: true
                }

                // Player name badge
                Rectangle {
                    visible: Boolean(popup.activePlayer && popup.activePlayer.identity)
                    implicitHeight: 20
                    implicitWidth: playerBadgeText.implicitWidth + 12
                    radius: 10
                    color: Theme.surface0

                    Text {
                        id: playerBadgeText
                        anchors.centerIn: parent
                        text: (popup.activePlayer && popup.activePlayer.identity) ? popup.activePlayer.identity : ""
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.Medium
                        color: Theme.mauve
                    }
                }
            }

            // Track info and Album art
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // Album Art
                Rectangle {
                    implicitWidth: 68
                    implicitHeight: 68
                    radius: 8
                    clip: true
                    color: Theme.surface0
                    border.color: Theme.glassBorder
                    border.width: 1

                    Image {
                        id: albumArtImg
                        anchors.fill: parent
                        source: popup.artUrl
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: popup.artUrl !== "" && status === Image.Ready
                    }

                    Text {
                        visible: !albumArtImg.visible
                        anchors.centerIn: parent
                        text: "󰎆"
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 28
                        color: Theme.surface2
                    }
                }

                // Title, Artist, Album
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    Text {
                        text: popup.title
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: Theme.text
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: popup.artist
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.subtext
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        visible: popup.album !== ""
                        text: popup.album
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Theme.overlay
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }

            // Timeline / Seekbar
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                visible: Boolean(popup.activePlayer && popup.activePlayer.lengthSupported && popup.activePlayer.length > 0)

                // Seek slider
                Item {
                    Layout.fillWidth: true
                    implicitHeight: 14

                    Rectangle {
                        id: seekTrack
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        height: 4
                        radius: 2
                        color: Theme.surface0

                        Rectangle {
                            height: parent.height
                            radius: parent.radius
                            color: Theme.mauve
                            width: {
                                if (!popup.activePlayer || !popup.activePlayer.length || popup.activePlayer.length <= 0) return 0;
                                const pos = popup.activePlayer.position || 0;
                                const len = popup.activePlayer.length || 1;
                                const frac = Math.min(1.0, Math.max(0.0, pos / len));
                                return Number.isFinite(frac) ? parent.width * frac : 0;
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: (mouse) => {
                            if (popup.activePlayer && popup.activePlayer.canSeek && popup.activePlayer.length > 0) {
                                const frac = Math.max(0.0, Math.min(1.0, mouse.x / width));
                                popup.activePlayer.position = frac * popup.activePlayer.length;
                            }
                        }
                    }
                }

                // Timestamps (Current / Total)
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: popup.formatTime(popup.activePlayer ? popup.activePlayer.position : 0)
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        color: Theme.overlay
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: popup.formatTime(popup.activePlayer ? popup.activePlayer.length : 0)
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        color: Theme.overlay
                    }
                }
            }

            // Playback Controls Row
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 14

                // Previous
                Rectangle {
                    implicitWidth: 32
                    implicitHeight: 32
                    radius: 16
                    color: prevMouse.containsMouse ? Theme.surface1 : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "󰒮"
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 16
                        color: Theme.text
                    }

                    MouseArea {
                        id: prevMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (popup.activePlayer && popup.activePlayer.canGoPrevious) {
                                popup.activePlayer.previous();
                            }
                        }
                    }
                }

                // Play / Pause (Large central button)
                Rectangle {
                    implicitWidth: 42
                    implicitHeight: 42
                    radius: 21
                    color: playMouse.containsMouse ? Theme.mauve : Qt.rgba(Theme.mauve.r, Theme.mauve.g, Theme.mauve.b, 0.85)

                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: popup.isPlaying ? "󰏤" : "󰐊"
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 20
                        color: Theme.crust
                    }

                    MouseArea {
                        id: playMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (popup.activePlayer && popup.activePlayer.canTogglePlaying) {
                                popup.activePlayer.togglePlaying();
                            }
                        }
                    }
                }

                // Next
                Rectangle {
                    implicitWidth: 32
                    implicitHeight: 32
                    radius: 16
                    color: nextMouse.containsMouse ? Theme.surface1 : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "󰒭"
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 16
                        color: Theme.text
                    }

                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (popup.activePlayer && popup.activePlayer.canGoNext) {
                                popup.activePlayer.next();
                            }
                        }
                    }
                }
            }

            // Multiple players switcher (if > 1)
            RowLayout {
                visible: Boolean(popup.players && popup.players.length > 1)
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: popup.players

                    delegate: Rectangle {
                        id: playerTab
                        required property var modelData
                        required property int index

                        implicitHeight: 22
                        implicitWidth: pTabText.implicitWidth + 14
                        radius: 11
                        color: index === popup.selectedPlayerIndex ? Theme.mauve : (pTabMouse.containsMouse ? Theme.surface1 : Theme.surface0)

                        Text {
                            id: pTabText
                            anchors.centerIn: parent
                            text: playerTab.modelData.identity || ("Player " + (playerTab.index + 1))
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.Medium
                            color: playerTab.index === popup.selectedPlayerIndex ? Theme.crust : Theme.text
                        }

                        MouseArea {
                            id: pTabMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: popup.selectedPlayerIndex = playerTab.index
                        }
                    }
                }
            }
        }
    }
}
