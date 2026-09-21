import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"
import "../services"

PopupWindow {
    id: popup

    property var anchorItem: null
    property var anchorWindow: null

    anchor {
        window: popup.anchorWindow
        item: popup.anchorItem
        edges: Edges.Bottom | Edges.Left
        gravity: Edges.Bottom | Edges.Right
        margins.top: 8
        rect.x: popup.anchorItem ? -Math.round((popup.implicitWidth - popup.anchorItem.width) / 2) : 0
    }

    grabFocus: true
    visible: false
    color: "transparent"
    implicitWidth: 350
    implicitHeight: mainCard.implicitHeight

    // Active Tab: 0 = Pomodoro, 1 = Kalender
    property int activeTab: 0

    // Calendar state
    property var today: new Date()
    property var selectedDate: new Date()
    property int displayYear: today.getFullYear()
    property int displayMonth: today.getMonth() // 0-indexed

    function nextMonth() {
        if (displayMonth === 11) {
            displayMonth = 0;
            displayYear++;
        } else {
            displayMonth++;
        }
    }

    function prevMonth() {
        if (displayMonth === 0) {
            displayMonth = 11;
            displayYear--;
        } else {
            displayMonth--;
        }
    }

    function resetToToday() {
        today = new Date();
        displayYear = today.getFullYear();
        displayMonth = today.getMonth();
        selectedDate = new Date();
    }

    readonly property var monthNames: [
        "Januar", "Februar", "März", "April", "Mai", "Juni",
        "Juli", "August", "September", "Oktober", "November", "Dezember"
    ]

    readonly property var calendarGrid: {
        const firstDayDate = new Date(displayYear, displayMonth, 1);
        // European start of week: Monday is 0, Sunday is 6
        let startDay = (firstDayDate.getDay() + 6) % 7;
        const daysInMonth = new Date(displayYear, displayMonth + 1, 0).getDate();
        const daysInPrevMonth = new Date(displayYear, displayMonth, 0).getDate();

        const cells = [];
        const prevM = displayMonth === 0 ? 11 : displayMonth - 1;
        const prevY = displayMonth === 0 ? displayYear - 1 : displayYear;
        for (let i = startDay - 1; i >= 0; i--) {
            cells.push({
                day: daysInPrevMonth - i,
                month: prevM,
                year: prevY,
                isCurrentMonth: false,
                isToday: false
            });
        }
        for (let i = 1; i <= daysInMonth; i++) {
            const isToday = (
                i === today.getDate() &&
                displayMonth === today.getMonth() &&
                displayYear === today.getFullYear()
            );
            cells.push({
                day: i,
                month: displayMonth,
                year: displayYear,
                isCurrentMonth: true,
                isToday: isToday
            });
        }
        const nextM = displayMonth === 11 ? 0 : displayMonth + 1;
        const nextY = displayMonth === 11 ? displayYear + 1 : displayYear;
        const totalNeeded = cells.length > 35 ? 42 : 35;
        const remaining = totalNeeded - cells.length;
        for (let i = 1; i <= remaining; i++) {
            cells.push({
                day: i,
                month: nextM,
                year: nextY,
                isCurrentMonth: false,
                isToday: false
            });
        }
        return cells;
    }

    Rectangle {
        id: mainCard
        anchors.fill: parent
        radius: Theme.radiusCard
        color: "#f21e1e2e" // High opacity Catppuccin Mocha
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

            // Top Header: Tabs (Pomodoro / Kalender) & Close Button
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                // Tab Selector Pill
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 34
                    radius: 17
                    color: Theme.surface0

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 3
                        spacing: 2

                        // Tab 0: Pomodoro
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 14
                            color: popup.activeTab === 0 ? Theme.surface1 : "transparent"

                            Behavior on color { ColorAnimation { duration: 120 } }

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: PomodoroService.modeIcon
                                    font.family: Theme.iconFontFamily
                                    font.pixelSize: 13
                                    color: PomodoroService.isRunning ? PomodoroService.modeColor : (popup.activeTab === 0 ? Theme.text : Theme.subtext)
                                }

                                Text {
                                    text: "Pomodoro"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 12
                                    font.weight: popup.activeTab === 0 ? Font.DemiBold : Font.Normal
                                    color: popup.activeTab === 0 ? Theme.text : Theme.subtext
                                }

                                // Subtle pulse dot if running
                                Rectangle {
                                    visible: PomodoroService.isRunning
                                    implicitWidth: 6
                                    implicitHeight: 6
                                    radius: 3
                                    color: PomodoroService.modeColor
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: popup.activeTab = 0
                            }
                        }

                        // Tab 1: Kalender
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 14
                            color: popup.activeTab === 1 ? Theme.surface1 : "transparent"

                            Behavior on color { ColorAnimation { duration: 120 } }

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: "󰃭"
                                    font.family: Theme.iconFontFamily
                                    font.pixelSize: 13
                                    color: popup.activeTab === 1 ? Theme.blue : Theme.subtext
                                }

                                Text {
                                    text: "Kalender"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 12
                                    font.weight: popup.activeTab === 1 ? Font.DemiBold : Font.Normal
                                    color: popup.activeTab === 1 ? Theme.text : Theme.subtext
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: popup.activeTab = 1
                            }
                        }
                    }
                }

                // Close button
                Rectangle {
                    implicitWidth: 24
                    implicitHeight: 24
                    radius: 12
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

            // ==========================================
            // TAB 0: POMODORO TIMER VIEW
            // ==========================================
            ColumnLayout {
                Layout.fillWidth: true
                visible: popup.activeTab === 0
                spacing: 12

                // Mode Selector Bar (Fokus, Pause, Lang)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    // Fokus (25m)
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 28
                        radius: 8
                        color: PomodoroService.currentMode === PomodoroService.modeFocus ? Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, 0.18) : Theme.surface0
                        border.color: PomodoroService.currentMode === PomodoroService.modeFocus ? Theme.red : "transparent"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "Fokus (25m)"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: PomodoroService.currentMode === PomodoroService.modeFocus ? Theme.red : Theme.subtext
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PomodoroService.setMode(PomodoroService.modeFocus)
                        }
                    }

                    // Kurze Pause (5m)
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 28
                        radius: 8
                        color: PomodoroService.currentMode === PomodoroService.modeShortBreak ? Qt.rgba(Theme.green.r, Theme.green.g, Theme.green.b, 0.18) : Theme.surface0
                        border.color: PomodoroService.currentMode === PomodoroService.modeShortBreak ? Theme.green : "transparent"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "Pause (5m)"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: PomodoroService.currentMode === PomodoroService.modeShortBreak ? Theme.green : Theme.subtext
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PomodoroService.setMode(PomodoroService.modeShortBreak)
                        }
                    }

                    // Lange Pause (15m)
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 28
                        radius: 8
                        color: PomodoroService.currentMode === PomodoroService.modeLongBreak ? Qt.rgba(Theme.blue.r, Theme.blue.g, Theme.blue.b, 0.18) : Theme.surface0
                        border.color: PomodoroService.currentMode === PomodoroService.modeLongBreak ? Theme.blue : "transparent"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "Lang (15m)"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: PomodoroService.currentMode === PomodoroService.modeLongBreak ? Theme.blue : Theme.subtext
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PomodoroService.setMode(PomodoroService.modeLongBreak)
                        }
                    }
                }

                // Main Timer Countdown Card
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 110
                    radius: 12
                    color: Theme.surface0

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: PomodoroService.formattedTime
                            font.family: Theme.fontFamily
                            font.pixelSize: 42
                            font.weight: Font.Bold
                            color: PomodoroService.isRunning ? PomodoroService.modeColor : Theme.text
                        }

                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 6

                            Text {
                                text: PomodoroService.modeIcon
                                font.family: Theme.iconFontFamily
                                font.pixelSize: 12
                                color: PomodoroService.modeColor
                            }

                            Text {
                                text: PomodoroService.modeName + (PomodoroService.isRunning ? " läuft..." : " pausiert")
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                color: Theme.subtext
                            }
                        }
                    }

                    // Circular / Line Progress Bar at bottom of card
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        implicitHeight: 4
                        color: Theme.surface1
                        radius: 2

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: parent.width * PomodoroService.progress
                            color: PomodoroService.modeColor
                            radius: 2

                            Behavior on width { NumberAnimation { duration: 250 } }
                        }
                    }
                }

                // Action Controls: Reset, Big Play/Pause, Skip
                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 14

                    // Reset button
                    Rectangle {
                        implicitWidth: 38
                        implicitHeight: 38
                        radius: 19
                        color: resetMouse.containsMouse ? Theme.surface1 : Theme.surface0

                        Text {
                            anchors.centerIn: parent
                            text: "󰑐"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 16
                            color: Theme.subtext
                        }

                        MouseArea {
                            id: resetMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PomodoroService.reset()
                        }
                    }

                    // Big Start / Pause Button
                    Rectangle {
                        Layout.preferredWidth: 120
                        implicitHeight: 42
                        radius: 21
                        color: playBtnMouse.containsMouse 
                            ? Qt.darker(PomodoroService.modeColor, 1.1) 
                            : PomodoroService.modeColor

                        Behavior on color { ColorAnimation { duration: 120 } }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: PomodoroService.isRunning ? "󰏤" : "󰐊"
                                font.family: Theme.iconFontFamily
                                font.pixelSize: 16
                                color: Theme.crust
                            }

                            Text {
                                text: PomodoroService.isRunning ? "Pause" : "Starten"
                                font.family: Theme.fontFamily
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: Theme.crust
                            }
                        }

                        MouseArea {
                            id: playBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PomodoroService.toggle()
                        }
                    }

                    // Skip button
                    Rectangle {
                        implicitWidth: 38
                        implicitHeight: 38
                        radius: 19
                        color: skipMouse.containsMouse ? Theme.surface1 : Theme.surface0

                        Text {
                            anchors.centerIn: parent
                            text: "󰒭"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 16
                            color: Theme.subtext
                        }

                        MouseArea {
                            id: skipMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PomodoroService.skip()
                        }
                    }
                }

                // Completed Pomodoros Counter Indicator
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 30
                    radius: 8
                    color: Theme.surface0

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: "Sessions abgeschlossen:"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            color: Theme.subtext
                        }

                        Text {
                            text: String(PomodoroService.completedPomodoros)
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: Theme.green
                        }

                        // Cycle dots
                        RowLayout {
                            spacing: 4

                            Repeater {
                                model: 4
                                delegate: Rectangle {
                                    implicitWidth: 8
                                    implicitHeight: 8
                                    radius: 4
                                    color: index < (PomodoroService.completedPomodoros % 4) ? Theme.green : Theme.surface2
                                }
                            }
                        }
                    }
                }
            }

            // ==========================================
            // TAB 1: KALENDER VIEW
            // ==========================================
            ColumnLayout {
                Layout.fillWidth: true
                visible: popup.activeTab === 1
                spacing: 10

                // Month Navigation Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    // Prev month button
                    Rectangle {
                        implicitWidth: 28
                        implicitHeight: 28
                        radius: 14
                        color: prevMthMouse.containsMouse ? Theme.surface1 : Theme.surface0

                        Text {
                            anchors.centerIn: parent
                            text: "󰅁"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 13
                            color: Theme.text
                        }

                        MouseArea {
                            id: prevMthMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: popup.prevMonth()
                        }
                    }

                    // Month & Year Label
                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: popup.monthNames[popup.displayMonth] + " " + popup.displayYear
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: Theme.text
                    }

                    // Next month button
                    Rectangle {
                        implicitWidth: 28
                        implicitHeight: 28
                        radius: 14
                        color: nextMthMouse.containsMouse ? Theme.surface1 : Theme.surface0

                        Text {
                            anchors.centerIn: parent
                            text: "󰅂"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 13
                            color: Theme.text
                        }

                        MouseArea {
                            id: nextMthMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: popup.nextMonth()
                        }
                    }

                    // Today reset button
                    Rectangle {
                        implicitWidth: 54
                        implicitHeight: 28
                        radius: 14
                        color: todayMouse.containsMouse ? Theme.blue : Theme.surface0

                        Text {
                            anchors.centerIn: parent
                            text: "Heute"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: todayMouse.containsMouse ? Theme.crust : Theme.subtext
                        }

                        MouseArea {
                            id: todayMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: popup.resetToToday()
                        }
                    }
                }

                // Weekdays Header Row (Mo, Di, Mi, Do, Fr, Sa, So)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Repeater {
                        model: ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
                        delegate: Item {
                            Layout.fillWidth: true
                            implicitHeight: 22

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: (modelData === "Sa" || modelData === "So") ? Theme.peach : Theme.overlay
                            }
                        }
                    }
                }

                // Month Calendar Days Grid
                GridLayout {
                    Layout.fillWidth: true
                    columns: 7
                    rowSpacing: 4
                    columnSpacing: 4

                    Repeater {
                        model: popup.calendarGrid

                        delegate: Rectangle {
                            id: dayDelegate
                            required property var modelData

                            readonly property bool isSelected: Boolean(
                                popup.selectedDate &&
                                popup.selectedDate.getDate() === modelData.day &&
                                popup.selectedDate.getMonth() === modelData.month &&
                                popup.selectedDate.getFullYear() === modelData.year
                            )

                            Layout.fillWidth: true
                            implicitHeight: 32
                            radius: 16
                            color: {
                                if (modelData.isToday) return Theme.blue;
                                if (isSelected) return Theme.surface1;
                                if (dayMouse.containsMouse) return Theme.surface0;
                                return "transparent";
                            }
                            border.color: isSelected && !modelData.isToday ? Theme.blue : "transparent"
                            border.width: 1.5

                            Behavior on color { ColorAnimation { duration: 100 } }
                            Behavior on border.color { ColorAnimation { duration: 100 } }

                            Text {
                                anchors.centerIn: parent
                                text: String(modelData.day)
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.weight: (modelData.isToday || isSelected) ? Font.Bold : (modelData.isCurrentMonth ? Font.Medium : Font.Normal)
                                color: {
                                    if (modelData.isToday) return Theme.crust;
                                    if (isSelected) return Theme.blue;
                                    return modelData.isCurrentMonth ? Theme.text : Theme.surface2;
                                }
                            }

                            MouseArea {
                                id: dayMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (!modelData.isCurrentMonth) {
                                        popup.displayMonth = modelData.month;
                                        popup.displayYear = modelData.year;
                                    }
                                    popup.selectedDate = new Date(modelData.year, modelData.month, modelData.day);
                                }
                            }
                        }
                    }
                }

                // Selected Day Status Banner
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 34
                    radius: 8
                    color: Theme.surface0

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: "󰃭"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 13
                            color: Theme.blue
                        }

                        Text {
                            text: Qt.formatDate(popup.selectedDate, "dddd, dd. MMMM yyyy")
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: Theme.text
                        }
                    }
                }
            }
        }
    }
}
