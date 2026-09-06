import QtQuick
import QtQuick.Layouts
import "../../services" as Services

// Compact wifi/LAN/VPN status; click opens NetworkMenu for details and
// connecting/disconnecting.
Item {
    id: root
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    RowLayout {
        id: row
        anchors.fill: parent
        spacing: 6

        Text {
            visible: Services.Network.wiredSupported && Services.Network.wiredConnected
            text: "🖧"
            font.pixelSize: 12
            color: Services.Colors.text
        }

        Text {
            visible: Services.Network.wifiSupported
            text: "📶"
            font.pixelSize: 12
            color: {
                if (!Services.Network.wifiEnabled) return Services.Colors.disabled;
                if (Services.Network.activeWifiNetwork) return Services.Colors.text;
                return Services.Colors.subtext;
            }
        }

        Text {
            visible: Services.Vpn.available && Services.Vpn.anyActive
            text: "🔒"
            font.pixelSize: 11
            color: Services.Colors.accent
        }

        Text {
            visible: !Services.Network.wifiSupported && !Services.Network.wiredSupported
            text: "no network"
            font.pixelSize: 11
            color: Services.Colors.disabled
        }
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -4
        cursorShape: Qt.PointingHandCursor
        onClicked: Services.UiState.toggleNetworkMenu()
    }
}
