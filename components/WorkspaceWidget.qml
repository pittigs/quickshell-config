import QtQuick
import QtQuick.Layouts
import "../theme"
import "../services"

Pill {
    id: root

    implicitHeight: 34
    implicitWidth: layout.implicitWidth + 14
    hoverable: false

    onWheelUp: WorkspaceService.previous()
    onWheelDown: WorkspaceService.next()

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: WorkspaceService.desktops

            delegate: Rectangle {
                id: deskItem
                required property int modelData
                readonly property bool isActive: modelData === WorkspaceService.currentDesktop

                implicitWidth: isActive ? 26 : 22
                implicitHeight: 22
                radius: 11
                color: {
                    if (isActive) return Theme.mauve
                    if (itemMouse.containsMouse) return Theme.surface1
                    return "transparent"
                }

                Behavior on implicitWidth {
                    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                }

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                Text {
                    anchors.centerIn: parent
                    text: String(deskItem.modelData)
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: deskItem.isActive
                    color: deskItem.isActive ? Theme.crust : (itemMouse.containsMouse ? Theme.text : Theme.subtext)

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                MouseArea {
                    id: itemMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: WorkspaceService.switchTo(deskItem.modelData)
                }
            }
        }

        // Add workspace button (if under 8 desktops)
        Rectangle {
            visible: WorkspaceService.desktopCount < 8
            implicitWidth: 18
            implicitHeight: 18
            radius: 9
            color: addMouse.containsMouse ? Theme.surface1 : "transparent"

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            Text {
                anchors.centerIn: parent
                text: "+"
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
                color: addMouse.containsMouse ? Theme.mauve : Theme.overlay
            }

            MouseArea {
                id: addMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: WorkspaceService.createNewDesktop()
            }
        }
    }
}
