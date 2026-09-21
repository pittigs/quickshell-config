import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland._ToplevelManagement
import "../theme"

Pill {
    id: root

    readonly property var toplevel: ToplevelManager.activeToplevel
    readonly property bool hasWindow: Boolean(toplevel && toplevel.title && toplevel.title.trim().length > 0)
    readonly property string windowTitle: hasWindow ? toplevel.title : ""
    readonly property string appId: hasWindow ? (toplevel.appId || "") : ""

    visible: root.hasWindow
    clickable: true
    implicitHeight: 34
    implicitWidth: layout.implicitWidth + 20

    onClicked: {
        if (root.toplevel) {
            root.toplevel.activate();
        }
    }

    onRightClicked: {
        if (root.toplevel) {
            root.toplevel.maximized = !root.toplevel.maximized;
        }
    }

    onMiddleClicked: {
        if (root.toplevel) {
            root.toplevel.close();
        }
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 6

        // Window / App Icon
        Rectangle {
            implicitWidth: 18
            implicitHeight: 18
            color: "transparent"

            IconImage {
                id: appIcon
                anchors.centerIn: parent
                width: 16
                height: 16
                source: root.appId ? ("image://icon/" + root.appId) : ""
                visible: status === Image.Ready
            }

            Text {
                visible: !appIcon.visible
                anchors.centerIn: parent
                text: "󰖲"
                font.family: Theme.iconFontFamily
                font.pixelSize: 13
                color: root.hovered ? Theme.mauve : Theme.blue

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }
        }

        // Title text
        Text {
            text: root.windowTitle
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.Medium
            color: root.hovered ? Theme.text : Theme.subtext
            elide: Text.ElideRight
            Layout.maximumWidth: 200

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }
    }
}
