pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../../services" as Services

// StatusNotifier system tray. Applications provide the icon, activation
// behavior, scroll handling, and (where available) the native context menu.
RowLayout {
    id: root
    spacing: 4
    visible: trayItems.count > 0

    Repeater {
        id: trayItems
        model: SystemTray.items

        delegate: Rectangle {
            id: tile
            required property SystemTrayItem modelData

            implicitWidth: 24
            implicitHeight: 24
            radius: Services.Colors.radiusSmall
            color: pointer.containsMouse ? Services.Colors.overlay : "transparent"

            function showMenu() {
                if (!modelData.hasMenu) return;
                const point = tile.mapToItem(null, 0, tile.height + 4);
                modelData.display(QsWindow.window, point.x, point.y);
            }

            Behavior on color { ColorAnimation { duration: 100 } }

            IconImage {
                anchors.centerIn: parent
                implicitSize: 17
                source: tile.modelData.icon
            }

            MouseArea {
                id: pointer
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: mouse => {
                    if (mouse.button === Qt.MiddleButton) {
                        tile.modelData.secondaryActivate();
                    } else if (mouse.button === Qt.RightButton) {
                        if (tile.modelData.hasMenu) tile.showMenu();
                    } else if (tile.modelData.onlyMenu) {
                        if (tile.modelData.hasMenu) tile.showMenu();
                    } else {
                        tile.modelData.activate();
                    }
                }

                onWheel: wheel => {
                    const horizontal = Math.abs(wheel.angleDelta.x) > Math.abs(wheel.angleDelta.y);
                    const delta = horizontal ? wheel.angleDelta.x : wheel.angleDelta.y;
                    tile.modelData.scroll(delta, horizontal);
                    wheel.accepted = true;
                }
            }
        }
    }
}
