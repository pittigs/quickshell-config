import QtQuick
import QtQuick.Layouts
import "../theme"

Pill {
    id: root

    property var parentWindow: null

    clickable: true
    implicitHeight: 34
    implicitWidth: 38
    active: notesPopup.visible

    NotesPopup {
        id: notesPopup
        anchorItem: root
        anchorWindow: root.parentWindow
    }

    onClicked: {
        notesPopup.visible = !notesPopup.visible;
    }

    Text {
        anchors.centerIn: parent
        text: "󰏫"
        font.family: Theme.iconFontFamily
        font.pixelSize: 15
        color: root.hovered || root.active ? Theme.yellow : Theme.subtext

        Behavior on color { ColorAnimation { duration: 150 } }
    }
}
