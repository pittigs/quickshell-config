import QtQuick
import QtQuick.Layouts
import "../theme"

Pill {
    id: root

    property var parentWindow: null

    clickable: true
    implicitHeight: 34
    implicitWidth: 38
    active: powerPopup.visible

    // Power popup instance anchored to this button
    PowerMenu {
        id: powerPopup
        anchorItem: root
        anchorWindow: root.parentWindow
    }

    onClicked: {
        powerPopup.visible = !powerPopup.visible
    }

    onRightClicked: {
        powerPopup.visible = !powerPopup.visible
    }

    Text {
        anchors.centerIn: parent
        text: "󰐥"
        font.family: Theme.iconFontFamily
        font.pixelSize: 17
        color: root.hovered || root.active ? Theme.red : Theme.peach

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }
}
