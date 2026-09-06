import Quickshell
import Quickshell.Wayland
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts
import "../services" as Services
import "./widgets" as Widgets

// Wifi/LAN/VPN details and controls, opened from the bar's network icon.
PanelWindow {
    id: root

    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    readonly property bool menuOpen: Services.UiState.networkMenuOpen
    visible: menuOpen || panel.animating

    WlrLayershell.namespace: "molunga-network-menu"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    // Anchored to all four edges (rather than just top+right) so the
    // window covers the whole output: that's what lets a click anywhere
    // outside the panel below reach this window and close the menu, via
    // Widgets.DismissOverlay.
    anchors.top: true
    anchors.right: true
    anchors.bottom: true
    anchors.left: true
    color: "transparent"

    // Cleared whenever the menu closes, so a half-typed password doesn't
    // linger for next time.
    property var pskTarget: null
    property string pskInput: ""

    onMenuOpenChanged: {
        if (menuOpen) dismissOverlay.forceActiveFocus();
        else { pskTarget = null; pskInput = ""; }
    }

    Widgets.DismissOverlay {
        id: dismissOverlay
        onDismissed: Services.UiState.networkMenuOpen = false
    }

    Widgets.PopupPanel {
        id: panel
        open: root.menuOpen
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 4
        width: 340
        implicitHeight: content.implicitHeight

        // Absorbs clicks anywhere on the panel (not just its interactive
        // controls) so they don't fall through to the dismiss overlay.
        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            id: content
            width: parent.width
            spacing: 10

            // --- Wi-Fi -----------------------------------------------------

            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 10
                spacing: 6
                visible: Services.Network.wifiSupported

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        Layout.fillWidth: true
                        text: "Wi-Fi"
                        color: Services.Colors.text
                        font.pixelSize: 13
                        font.bold: true
                    }
                    Widgets.ToggleSwitch {
                        checked: Services.Network.wifiEnabled
                        onToggled: Services.Network.setWifiEnabled(!Services.Network.wifiEnabled)
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    visible: Services.Network.wifiEnabled

                    Repeater {
                        model: Services.Network.wifiNetworks

                        delegate: ColumnLayout {
                            id: row
                            required property var modelData

                            Layout.fillWidth: true
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                RowLayout {
                                    spacing: 1
                                    Repeater {
                                        model: 4
                                        delegate: Rectangle {
                                            required property int index
                                            width: 3
                                            height: 4 + index * 2
                                            Layout.alignment: Qt.AlignBottom
                                            color: index < Services.Network.signalBars(row.modelData)
                                                ? (row.modelData.connected ? Services.Colors.accent : Services.Colors.subtext)
                                                : Services.Colors.overlay
                                        }
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: row.modelData.name
                                    color: Services.Colors.text
                                    font.pixelSize: 12
                                    font.bold: row.modelData.connected
                                    elide: Text.ElideRight
                                }

                                Text {
                                    visible: Services.Network.isSecured(row.modelData)
                                    text: "lock"
                                    font.family: Services.Icons.family
                                    font.pixelSize: 11
                                    color: Services.Colors.subtext
                                }

                                Text {
                                    visible: row.modelData.connected
                                    text: "connected"
                                    color: Services.Colors.accent
                                    font.pixelSize: 10
                                }

                                Text {
                                    visible: !row.modelData.connected
                                    text: "connect"
                                    color: Services.Colors.subtext
                                    font.pixelSize: 10
                                    MouseArea {
                                        anchors.fill: parent
                                        anchors.margins: -4
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (Services.Network.isSecured(row.modelData) && !row.modelData.known) {
                                                root.pskTarget = row.modelData;
                                                root.pskInput = "";
                                            } else {
                                                Services.Network.connect(row.modelData);
                                            }
                                        }
                                    }
                                }

                                Text {
                                    visible: row.modelData.connected
                                    text: "disconnect"
                                    color: Services.Colors.subtext
                                    font.pixelSize: 10
                                    MouseArea {
                                        anchors.fill: parent
                                        anchors.margins: -4
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Services.Network.disconnect(row.modelData)
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                visible: root.pskTarget === row.modelData
                                spacing: 4

                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: 24
                                    radius: Services.Colors.radiusSmall
                                    color: Services.Colors.surfaceAlt
                                    border.width: 1
                                    border.color: pskField.activeFocus ? Services.Colors.accent : Services.Colors.border

                                    TextInput {
                                        id: pskField
                                        anchors.fill: parent
                                        anchors.leftMargin: 6
                                        anchors.rightMargin: 6
                                        verticalAlignment: TextInput.AlignVCenter
                                        color: Services.Colors.text
                                        font.pixelSize: 11
                                        echoMode: TextInput.Password
                                        clip: true
                                        text: root.pskInput
                                        onTextChanged: root.pskInput = text
                                        onAccepted: {
                                            Services.Network.connectWithPsk(row.modelData, root.pskInput);
                                            root.pskTarget = null;
                                        }
                                    }
                                }

                                Text {
                                    text: "join"
                                    color: Services.Colors.accent
                                    font.pixelSize: 11
                                    MouseArea {
                                        anchors.fill: parent
                                        anchors.margins: -4
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            Services.Network.connectWithPsk(row.modelData, root.pskInput);
                                            root.pskTarget = null;
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        visible: Services.Network.wifiNetworks.length === 0
                        text: "No networks found"
                        color: Services.Colors.disabled
                        font.pixelSize: 11
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                visible: Services.Network.wifiSupported && (Services.Network.wiredSupported || Services.Vpn.available)
                implicitHeight: 1
                color: Services.Colors.border
            }

            // --- Wired -------------------------------------------------------

            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 10
                visible: Services.Network.wiredSupported

                Text {
                    Layout.fillWidth: true
                    text: "Wired" + (Services.Network.wiredName ? " (" + Services.Network.wiredName + ")" : "")
                    color: Services.Colors.text
                    font.pixelSize: 12
                }
                Text {
                    text: Services.Network.wiredConnected ? "connected" : "disconnected"
                    color: Services.Network.wiredConnected ? Services.Colors.accent : Services.Colors.disabled
                    font.pixelSize: 11
                }
            }

            // --- VPN -----------------------------------------------------------

            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 10
                spacing: 4
                visible: Services.Vpn.available && Services.Vpn.connections.length > 0

                Text {
                    text: "VPN"
                    color: Services.Colors.text
                    font.pixelSize: 13
                    font.bold: true
                }

                Repeater {
                    model: Services.Vpn.connections

                    delegate: RowLayout {
                        id: vpnRow
                        required property var modelData
                        Layout.fillWidth: true

                        Text {
                            Layout.fillWidth: true
                            text: vpnRow.modelData.name
                            color: Services.Colors.text
                            font.pixelSize: 12
                            elide: Text.ElideRight
                        }
                        Widgets.ToggleSwitch {
                            checked: vpnRow.modelData.active
                            onToggled: vpnRow.modelData.active
                                ? Services.Vpn.disconnect(vpnRow.modelData.name)
                                : Services.Vpn.connect(vpnRow.modelData.name)
                        }
                    }
                }
            }
        }
    }
}
