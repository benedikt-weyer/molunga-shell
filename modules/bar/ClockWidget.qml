import QtQuick
import "../../services" as Services

Text {
    id: root

    property date now: new Date()

    text: Qt.formatDateTime(now, "ddd d MMM  HH:mm")
    color: Services.Colors.text
    font.pixelSize: 12
    font.bold: true

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }
}
