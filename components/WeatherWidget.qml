import QtQuick
import QtQuick.Layouts
import "../theme"
import "../services"

Pill {
    id: root

    property var parentWindow: null

    clickable: true
    implicitHeight: 34
    implicitWidth: layout.implicitWidth + 22
    active: weatherPopup.visible

    WeatherPopup {
        id: weatherPopup
        anchorItem: root
        anchorWindow: root.parentWindow
    }

    onClicked: {
        weatherPopup.visible = !weatherPopup.visible;
    }

    onRightClicked: {
        WeatherService.refresh();
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: WeatherService.conditionIcon
            font.family: Theme.iconFontFamily
            font.pixelSize: 14
            color: root.hovered || weatherPopup.visible ? Theme.yellow : Theme.peach

            Behavior on color { ColorAnimation { duration: 150 } }
        }

        Text {
            text: WeatherService.temp
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.Medium
            color: Theme.text
        }
    }
}
