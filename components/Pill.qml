import QtQuick
import "../theme"

Rectangle {
    id: root

    property bool clickable: false
    property bool hoverable: true
    property bool active: false
    property alias hovered: mouseArea.containsMouse
    property color customBg: Theme.glassPill
    property color customBorder: Theme.glassBorder

    signal clicked()
    signal rightClicked()
    signal wheelUp()
    signal wheelDown()

    radius: Theme.radiusPill
    color: {
        if (active) return Theme.glassHover
        if (hoverable && mouseArea.containsMouse) return Theme.glassHover
        return customBg
    }
    border.color: {
        if (active) return Theme.blue
        if (hoverable && mouseArea.containsMouse) return Theme.glassBorderHover
        return customBorder
    }
    border.width: 1

    Behavior on color {
        ColorAnimation { duration: 150; easing.type: Easing.OutQuad }
    }
    Behavior on border.color {
        ColorAnimation { duration: 150; easing.type: Easing.OutQuad }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: root.hoverable
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                root.clicked()
            } else if (mouse.button === Qt.RightButton) {
                root.rightClicked()
            }
        }

        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) {
                root.wheelUp()
            } else if (wheel.angleDelta.y < 0) {
                root.wheelDown()
            }
        }
    }
}
