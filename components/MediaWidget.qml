import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import "../theme"

Pill {
    id: root

    implicitHeight: 34
    implicitWidth: layout.implicitWidth + 20

    // Pick active player (playing first, otherwise first available)
    readonly property var activePlayer: {
        const players = Mpris.players.values;
        if (!players || players.length === 0) return null;
        for (let i = 0; i < players.length; i++) {
            if (players[i].playbackState === MprisPlaybackState.Playing) {
                return players[i];
            }
        }
        return players[0];
    }

    readonly property bool hasMedia: activePlayer !== null
    readonly property bool isPlaying: hasMedia && activePlayer.playbackState === MprisPlaybackState.Playing
    readonly property string title: hasMedia ? (activePlayer.trackTitle || "Unbekannter Titel") : "Keine Medien"
    readonly property string artist: hasMedia ? (activePlayer.trackArtist || "") : ""

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 8

        Text {
            text: root.isPlaying ? "󰎈" : "󰎊"
            font.family: Theme.iconFontFamily
            font.pixelSize: 14
            color: root.isPlaying ? Theme.green : Theme.overlay

            Behavior on color {
                ColorAnimation { duration: 150 }
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
