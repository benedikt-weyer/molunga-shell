import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import "../services" as Services

// Toast stack, top-right of the primary screen, for unread notifications
// (Services.Notifications.active). Non-interactive placement-wise (doesn't
// grab focus or reserve space) so it never gets in the way of anything.
PanelWindow {
    id: root

    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    visible: screen !== null && Services.Notifications.active.length > 0

    WlrLayershell.namespace: "molunga-notifications"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors.top: true
    anchors.right: true
    implicitWidth: 340
    implicitHeight: column.implicitHeight + 16
    color: "transparent"

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6

        Repeater {
            model: Services.Notifications.active

            delegate: Rectangle {
                id: toast
                required property var modelData

                Layout.fillWidth: true
                implicitHeight: content.implicitHeight + 20
                radius: Services.Colors.radius
                color: Services.Colors.surface
                border.width: 1
                border.color: modelData.urgency === NotificationUrgency.Critical ? Services.Colors.danger : Services.Colors.border

                ColumnLayout {
                    id: content
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            Layout.fillWidth: true
                            text: toast.modelData.appName || toast.modelData.summary
                            color: Services.Colors.subtext
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                        Text {
                            text: "✕"
                            color: Services.Colors.subtext
                            font.pixelSize: 11
                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -4
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Services.Notifications.dismiss(toast.modelData)
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: toast.modelData.summary
                        color: Services.Colors.text
                        font.pixelSize: 13
                        font.bold: true
                        wrapMode: Text.Wrap
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: !!toast.modelData.body
                        text: toast.modelData.body
                        color: Services.Colors.subtext
                        font.pixelSize: 12
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
