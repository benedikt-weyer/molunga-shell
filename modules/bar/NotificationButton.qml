import QtQuick
import "../../services" as Services

Item {
    id: root
    implicitWidth: label.implicitWidth + 8
    implicitHeight: label.implicitHeight

    Text {
        id: label
        anchors.centerIn: parent
        text: Services.Notifications.history.length > 0 ? "🔔 " + Services.Notifications.history.length : "🔔"
        color: Services.UiState.notificationMenuOpen ? Services.Colors.accent : Services.Colors.text
        font.pixelSize: 12
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Services.UiState.toggleNotificationMenu()
    }
}
