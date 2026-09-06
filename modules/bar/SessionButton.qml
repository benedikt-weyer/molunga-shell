import QtQuick
import "../../services" as Services

Item {
    id: root
    implicitWidth: label.implicitWidth + 8
    implicitHeight: label.implicitHeight

    Text {
        id: label
        anchors.centerIn: parent
        text: "⏻"
        color: Services.UiState.sessionMenuOpen ? Services.Colors.accent : Services.Colors.text
        font.pixelSize: 14
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Services.UiState.toggleSessionMenu()
    }
}
