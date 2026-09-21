import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import "../theme"

Pill {
    id: root

    property var parentWindow: null

    clickable: true
    implicitHeight: 34
    implicitWidth: layout.implicitWidth + 20
    visible: root.hasMedia
    active: mediaPopup.visible
    customBorder: root.isPlaying ? Theme.surface2 : Theme.glassBorder

    MediaPopup {
        id: mediaPopup
        anchorItem: root
        anchorWindow: root.parentWindow
    }

    onClicked: {
        mediaPopup.visible = !mediaPopup.visible;
    }

    onMiddleClicked: {
        if (root.hasMedia && root.activePlayer && root.activePlayer.canTogglePlaying) {
            root.activePlayer.togglePlaying();
        }
    }

    onWheelUp: {
        if (root.hasMedia && root.activePlayer && root.activePlayer.volumeSupported) {
            root.activePlayer.volume = Math.min(1.0, root.activePlayer.volume + 0.05);
        }
    }

    onWheelDown: {
        if (root.hasMedia && root.activePlayer && root.activePlayer.volumeSupported) {
            root.activePlayer.volume = Math.max(0.0, root.activePlayer.volume - 0.05);
        }
    }

    // Pick active player (playing first, otherwise first available with valid track title)
    readonly property var activePlayer: {
        const players = Mpris.players.values;
        if (!players || players.length === 0) return null;
        for (let i = 0; i < players.length; i++) {
            if (players[i].playbackState === MprisPlaybackState.Playing) {
                return players[i];
            }
        }
        for (let i = 0; i < players.length; i++) {
            if (players[i].trackTitle && players[i].trackTitle.trim().length > 0) {
                return players[i];
            }
        }
        return null;
    }

    readonly property bool hasMedia: activePlayer !== null && Boolean(activePlayer.trackTitle && activePlayer.trackTitle.trim().length > 0)
    readonly property bool isPlaying: hasMedia && activePlayer.playbackState === MprisPlaybackState.Playing
    readonly property string title: hasMedia ? (activePlayer.trackTitle || "Unbekannter Titel") : "Keine Medien"
    readonly property string artist: hasMedia ? (activePlayer.trackArtist || "") : ""
    readonly property string artUrl: hasMedia ? (activePlayer.trackArtUrl || "") : ""

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 8

        // Icon or Album Art Thumbnail
        Rectangle {
            implicitWidth: 20
            implicitHeight: 20
            radius: 4
            clip: true
            color: "transparent"

            Image {
                id: albumArt
                visible: root.artUrl !== "" && status === Image.Ready
                anchors.fill: parent
                source: root.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }

            Text {
                visible: !albumArt.visible
                anchors.centerIn: parent
                text: root.isPlaying ? "󰎈" : "󰎊"
                font.family: Theme.iconFontFamily
                font.pixelSize: 14
                color: root.isPlaying ? Theme.green : Theme.overlay

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }
        }

        // Title and Artist text
        Text {
            visible: root.hasMedia
            text: root.artist ? (root.title + " • " + root.artist) : root.title
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.Medium
            color: Theme.text
            elide: Text.ElideRight
            Layout.preferredWidth: Math.min(implicitWidth, 180)
            Layout.maximumWidth: 180
        }

        // Mini controls
        RowLayout {
            visible: root.hasMedia
            spacing: 6

            // Previous button
            Rectangle {
                implicitWidth: 20
                implicitHeight: 20
                radius: 10
                color: prevMouse.containsMouse ? Theme.surface1 : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "󰒮"
                    font.family: Theme.iconFontFamily
                    font.pixelSize: 11
                    color: Theme.subtext
                }

                MouseArea {
                    id: prevMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.activePlayer && root.activePlayer.canGoPrevious) {
                            root.activePlayer.previous();
                        }
                    }
                }
            }

            // Play / Pause button
            Rectangle {
                implicitWidth: 22
                implicitHeight: 22
                radius: 11
                color: playMouse.containsMouse ? Theme.blue : Theme.surface1

                Text {
                    anchors.centerIn: parent
                    text: root.isPlaying ? "󰏤" : "󰐊"
                    font.family: Theme.iconFontFamily
                    font.pixelSize: 12
                    color: playMouse.containsMouse ? Theme.crust : Theme.text
                }

                MouseArea {
                    id: playMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.activePlayer && root.activePlayer.canTogglePlaying) {
                            root.activePlayer.togglePlaying();
                        }
                    }
                }
            }

            // Next button
            Rectangle {
                implicitWidth: 20
                implicitHeight: 20
                radius: 10
                color: nextMouse.containsMouse ? Theme.surface1 : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "󰒭"
                    font.family: Theme.iconFontFamily
                    font.pixelSize: 11
                    color: Theme.subtext
                }

                MouseArea {
                    id: nextMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.activePlayer && root.activePlayer.canGoNext) {
                            root.activePlayer.next();
                        }
                    }
                }
            }
        }
    }
}
