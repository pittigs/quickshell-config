import QtQuick
import QtQuick.Layouts
import "../theme"
import "../services"

Pill {
    id: root

    property var parentWindow: null

    clickable: true
    implicitHeight: 34
    implicitWidth: contentLayout.implicitWidth + 22
    active: clockPopup.visible

    property bool showDetails: false
    property var currentTime: new Date()

    ClockPopup {
        id: clockPopup
        anchorItem: root
        anchorWindow: root.parentWindow
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.currentTime = new Date();
        }
    }

    onClicked: {
        clockPopup.visible = !clockPopup.visible;
    }

    onRightClicked: {
        PomodoroService.toggle();
    }

    onMiddleClicked: {
        root.showDetails = !root.showDetails;
    }

    RowLayout {
        id: contentLayout
        anchors.centerIn: parent
        spacing: 7

        // Pomodoro Active Badge (shown when Pomodoro is running or active)
        RowLayout {
            visible: PomodoroService.isRunning || PomodoroService.timeRemaining !== PomodoroService.getDurationForMode(PomodoroService.currentMode)
            spacing: 5

            Rectangle {
                implicitWidth: 6
                implicitHeight: 6
                radius: 3
                color: PomodoroService.modeColor
                visible: PomodoroService.isRunning

                SequentialAnimation on opacity {
                    running: PomodoroService.isRunning
                    loops: Animation.Infinite
                    PropertyAnimation { to: 0.2; duration: 800; easing.type: Easing.InOutQuad }
                    PropertyAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                }
            }

            Text {
                text: PomodoroService.modeIcon
                font.family: Theme.iconFontFamily
                font.pixelSize: 13
                color: PomodoroService.modeColor
            }

            Text {
                text: PomodoroService.formattedTime
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.weight: Font.Bold
                color: PomodoroService.modeColor
            }

            Rectangle {
                implicitWidth: 1
                implicitHeight: 12
                color: Theme.surface1
                Layout.leftMargin: 2
            }
        }

        // Calendar Icon
        Text {
            text: "󰃭"
            font.family: Theme.iconFontFamily
            font.pixelSize: 13
            color: root.hovered || root.active ? Theme.mauve : Theme.blue

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }

        // Date Display
        Text {
            text: Qt.formatDateTime(root.currentTime, "ddd, dd. MMM")
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.Medium
            color: Theme.subtext
        }

        // Divider
        Rectangle {
            implicitWidth: 1
            implicitHeight: 12
            color: Theme.surface1
        }

        // Clock Display
        Text {
            text: root.showDetails 
                ? Qt.formatDateTime(root.currentTime, "HH:mm:ss")
                : Qt.formatDateTime(root.currentTime, "HH:mm")
            font.family: Theme.fontFamily
            font.pixelSize: 13
            font.weight: Font.Bold
            color: Theme.text
        }

        // Subtle Dropdown Indicator
        Text {
            text: "󰅀"
            font.family: Theme.iconFontFamily
            font.pixelSize: 11
            color: root.active ? Theme.blue : Theme.overlay

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }
    }
}
