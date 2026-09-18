import QtQuick
import QtQuick.Layouts
import "../theme"

Pill {
    id: root

    property var parentWindow: null

    clickable: true
    implicitHeight: 34
    implicitWidth: 38
    active: quickPopup.visible

    QuickSettingsPopup {
        id: quickPopup
        anchorItem: root
        anchorWindow: root.parentWindow
    }

    onClicked: {
        quickPopup.visible = !quickPopup.visible;
    }

    Text {
        anchors.centerIn: parent
        text: "󰍜"
        font.family: Theme.iconFontFamily
        font.pixelSize: 15
        color: root.hovered || root.active ? Theme.mauve : Theme.subtext

        Behavior on color { ColorAnimation { duration: 150 } }
    }
}
