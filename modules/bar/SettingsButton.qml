import QtQuick
import "../../services" as Services

Item {
    id: root
    implicitWidth: label.implicitWidth + 8
    implicitHeight: label.implicitHeight

    Text {
        id: label
        anchors.centerIn: parent
        text: "settings"
        font.family: Services.Icons.family
        color: Services.UiState.settingsOpen ? Services.Colors.accent : Services.Colors.text
        font.pixelSize: 15
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Services.UiState.toggleSettings()
    }
}
