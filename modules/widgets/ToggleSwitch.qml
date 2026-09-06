import QtQuick
import "../../services" as Services

// Shared on/off switch, used by SettingsWindow and NetworkMenu. Stateless -
// the caller owns `checked` and reacts to `toggled()`.
Rectangle {
    id: root

    property bool checked: false
    signal toggled()

    implicitWidth: 38
    implicitHeight: 20
    radius: 10
    color: checked ? Services.Colors.accent : Services.Colors.overlay
    Behavior on color { ColorAnimation { duration: 100 } }

    Rectangle {
        width: 16
        height: 16
        radius: 8
        y: 2
        x: root.checked ? root.width - width - 2 : 2
        color: Services.Colors.base
        Behavior on x { NumberAnimation { duration: 100 } }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
