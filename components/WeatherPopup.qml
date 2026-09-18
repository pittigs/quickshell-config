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
    implicitWidth: 320
    implicitHeight: mainCard.implicitHeight

    Rectangle {
        id: mainCard
        anchors.fill: parent
        radius: Theme.radiusCard
        color: "#f21e1e2e"
        border.color: Theme.glassBorder
        border.width: 1
        clip: true

        implicitHeight: contentCol.implicitHeight + 24

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

            // Header: Location & Actions
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    implicitWidth: 26
                    implicitHeight: 26
                    radius: 13
                    color: Qt.rgba(Theme.peach.r, Theme.peach.g, Theme.peach.b, 0.15)

                    Text {
                        anchors.centerIn: parent
                        text: "󰖐"
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 14
                        color: Theme.peach
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        text: "Wettervorhersage"
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: Theme.text
                    }

                    Text {
                        text: WeatherService.location + ", Deutschland"
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        color: Theme.subtext
                    }
                }

                // Refresh button
                Rectangle {
                    implicitWidth: 24
                    implicitHeight: 24
                    radius: 12
                    color: refreshMouse.containsMouse ? Theme.surface1 : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "󰑐"
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 12
                        color: Theme.subtext
                    }

                    MouseArea {
                        id: refreshMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: WeatherService.refresh()
                    }
                }

                // Close button
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

            // Current Weather Hero Card
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 90
                radius: 10
                color: Theme.surface0

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 14

                    Text {
                        text: WeatherService.conditionIcon
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 42
                        color: Theme.peach
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: WeatherService.temp
                            font.family: Theme.fontFamily
                            font.pixelSize: 30
                            font.weight: Font.Bold
                            color: Theme.text
                        }

                        Text {
                            text: WeatherService.description
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: Theme.subtext
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            // Metrics Row (Feels like, Humidity, Wind)
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                // Feels Like
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 46
                    radius: 8
                    color: Theme.surface0

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 1

                        Text { text: "Gefühlt"; font.family: Theme.fontFamily; font.pixelSize: 9; color: Theme.subtext }
                        Text { text: WeatherService.feelsLike; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text }
                    }
                }

                // Humidity
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 46
                    radius: 8
                    color: Theme.surface0

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 1

                        Text { text: "Feuchte"; font.family: Theme.fontFamily; font.pixelSize: 9; color: Theme.subtext }
                        Text { text: WeatherService.humidity; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.blue }
                    }
                }

                // Wind
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 46
                    radius: 8
                    color: Theme.surface0

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 1

                        Text { text: "Wind"; font.family: Theme.fontFamily; font.pixelSize: 9; color: Theme.subtext }
                        Text { text: WeatherService.wind; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.green }
                    }
                }
            }

            // 3-Day Forecast Section
            Text {
                text: "3-Tage-Vorhersage"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.weight: Font.Bold
                color: Theme.overlay
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: WeatherService.forecast

                    delegate: Rectangle {
                        id: forecastDelegate
                        required property var modelData

                        Layout.fillWidth: true
                        implicitHeight: 72
                        radius: 8
                        color: Theme.surface0

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 3

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: forecastDelegate.modelData.dayLabel
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                color: Theme.subtext
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: forecastDelegate.modelData.icon
                                font.family: Theme.iconFontFamily
                                font.pixelSize: 16
                                color: Theme.peach
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: forecastDelegate.modelData.min + " / " + forecastDelegate.modelData.max
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                color: Theme.text
                            }
                        }
                    }
                }
            }
        }
    }
}
