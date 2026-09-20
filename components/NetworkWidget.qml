import QtQuick
import QtQuick.Layouts
import "../theme"
import "../services"

Pill {
    id: root

    property var parentWindow: null

    clickable: true
    implicitHeight: 34
    implicitWidth: layout.implicitWidth + 24
    active: netPopup.visible

    NetworkPopup {
        id: netPopup
        anchorItem: root
        anchorWindow: root.parentWindow
    }

    onClicked: {
        netPopup.visible = !netPopup.visible;
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: NetworkService.interfaceIcon
            font.family: Theme.iconFontFamily
            font.pixelSize: 14
            color: {
                if (!NetworkService.isOnline) return Theme.red;
                if (root.hovered || netPopup.visible) return Theme.blue;
                return Theme.text;
            }

            Behavior on color { ColorAnimation { duration: 150 } }
        }

        Text {
            text: {
                if (!NetworkService.isOnline) return "Offline";
                if (NetworkService.downBytesSec > 50 * 1024) {
                    return "󰁅 " + NetworkService.downSpeedStr;
                }
                return NetworkService.isWifi ? "WLAN" : "LAN";
            }
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.Medium
            color: NetworkService.isOnline ? Theme.text : Theme.overlay
        }

        Text {
            text: "󰅀"
            font.family: Theme.iconFontFamily
            font.pixelSize: 10
            color: netPopup.visible ? Theme.blue : Theme.overlay
            opacity: root.hovered || netPopup.visible ? 1.0 : 0.6

            Behavior on opacity { NumberAnimation { duration: 150 } }
        }
    }
}
