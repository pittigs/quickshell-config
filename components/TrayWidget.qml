import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "../theme"

Pill {
    id: root

    implicitHeight: 34
    implicitWidth: layout.implicitWidth + 14
    visible: SystemTray.items.values.length > 0

    property var parentWindow: null

    Process {
        id: steamOpenProc
        command: ["steam", "steam://open/main"]
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: SystemTray.items.values

            delegate: Rectangle {
                id: itemDelegate
                required property var modelData

                implicitWidth: 24
                implicitHeight: 24
                radius: 6
                color: itemMouse.containsMouse ? Theme.surface1 : "transparent"

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                QsMenuAnchor {
                    id: menuAnchor
                    menu: itemDelegate.modelData.menu
                    anchor.item: itemDelegate
                }

                IconImage {
                    anchors.centerIn: parent
                    width: 18
                    height: 18
                    source: itemDelegate.modelData.icon
                }

                MouseArea {
                    id: itemMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: (mouse) => {
                        const targetWin = root.parentWindow ?? root.QsWindow.window;
                        if (mouse.button === Qt.RightButton) {
                            if (itemDelegate.modelData.menu) {
                                menuAnchor.open();
                            } else if (itemDelegate.modelData.hasMenu && targetWin) {
                                itemDelegate.modelData.display(targetWin, mouse.x, mouse.y);
                            } else {
                                itemDelegate.modelData.secondaryActivate();
                            }
                        } else {
                            if (itemDelegate.modelData.id === "steam") {
                                steamOpenProc.running = true;
                            } else if (itemDelegate.modelData.onlyMenu) {
                                if (itemDelegate.modelData.menu) {
                                    menuAnchor.open();
                                } else if (itemDelegate.modelData.hasMenu && targetWin) {
                                    itemDelegate.modelData.display(targetWin, mouse.x, mouse.y);
                                }
                            } else {
                                itemDelegate.modelData.activate();
                            }
                        }
                    }
                }
            }
        }
    }
}
