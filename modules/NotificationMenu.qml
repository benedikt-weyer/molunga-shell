import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../services" as Services

// Notification history/menu, opened from the bar's bell icon. Shows
// everything received this session (Services.Notifications.history), not
// just unread toasts.
PanelWindow {
    id: root

    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    visible: screen !== null && Services.UiState.notificationMenuOpen

    WlrLayershell.namespace: "molunga-notification-menu"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    anchors.top: true
    anchors.right: true
    margins.top: 4
    margins.right: 4
    implicitWidth: 360
    implicitHeight: Math.min(520, panel.implicitHeight)
    color: "transparent"

    Rectangle {
        id: panel
        anchors.fill: parent
        radius: Services.Colors.radius
        color: Services.Colors.surface
        border.width: 1
        border.color: Services.Colors.border
        implicitHeight: content.implicitHeight

        ColumnLayout {
            id: content
            width: parent.width
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 10

                Text {
                    Layout.fillWidth: true
                    text: "Notifications"
                    color: Services.Colors.text
                    font.pixelSize: 13
                    font.bold: true
                }

                Text {
                    text: "Clear"
                    visible: Services.Notifications.history.length > 0
                    color: Services.Colors.subtext
                    font.pixelSize: 11
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Services.Notifications.clearHistory()
                    }
                }
            }

            Text {
                visible: Services.Notifications.history.length === 0
                Layout.fillWidth: true
                Layout.margins: 16
                horizontalAlignment: Text.AlignHCenter
                text: "No notifications"
                color: Services.Colors.disabled
                font.pixelSize: 12
            }

            ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(440, contentHeight)
                clip: true
                model: Services.Notifications.history
                spacing: 4
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                    id: item
                    required property var modelData

                    width: ListView.view.width
                    height: entry.implicitHeight + 16
                    color: "transparent"

                    ColumnLayout {
                        id: entry
                        x: 10
                        width: parent.width - 20
                        y: 8
                        spacing: 1

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                Layout.fillWidth: true
                                text: item.modelData.appName || item.modelData.summary
                                color: Services.Colors.subtext
                                font.pixelSize: 10
                                elide: Text.ElideRight
                            }
                            Text {
                                text: Qt.formatTime(item.modelData.time, "HH:mm")
                                color: Services.Colors.disabled
                                font.pixelSize: 10
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: item.modelData.summary
                            color: Services.Colors.text
                            font.pixelSize: 12
                            font.bold: true
                            wrapMode: Text.Wrap
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: !!item.modelData.body
                            text: item.modelData.body
                            color: Services.Colors.subtext
                            font.pixelSize: 11
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }
}
