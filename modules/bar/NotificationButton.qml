import QtQuick
import QtQuick.Layouts
import "../../services" as Services

Item {
    id: root
    implicitWidth: row.implicitWidth + 8
    implicitHeight: row.implicitHeight

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 3

        Text {
            text: "notifications"
            font.family: Services.Icons.family
            font.pixelSize: 15
            color: Services.UiState.notificationMenuOpen ? Services.Colors.accent : Services.Colors.text
        }

        Text {
            visible: Services.Notifications.history.length > 0
            text: Services.Notifications.history.length
            color: Services.UiState.notificationMenuOpen ? Services.Colors.accent : Services.Colors.text
            font.pixelSize: 11
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Services.UiState.toggleNotificationMenu()
    }
}
