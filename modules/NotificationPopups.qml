import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import "../services" as Services
import "./widgets" as Widgets

// Toast stack, top-right of the primary screen, for unread notifications
// (Services.Notifications.active). Non-interactive placement-wise (doesn't
// grab focus or reserve space) so it never gets in the way of anything.
PanelWindow {
    id: root

    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    visible: Services.Notifications.active.length > 0

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

                // Slides/fades in on arrival rather than just popping into
                // place; `entered` flips true one tick after creation so
                // the Behaviors below have something to animate towards.
                property bool entered: false
                Component.onCompleted: toast.entered = true

                Layout.fillWidth: true
                implicitHeight: content.implicitHeight + 20
                radius: Services.Colors.radius
                color: Services.Colors.surface
                border.width: 1
                border.color: modelData.urgency === NotificationUrgency.Critical ? Services.Colors.danger : Services.Colors.border

                opacity: entered ? 1 : 0
                transform: Translate {
                    y: toast.entered ? 0 : -12
                    Behavior on y { Widgets.Anim { type: Widgets.Anim.DefaultSpatial } }
                }
                Behavior on opacity { Widgets.Anim { type: Widgets.Anim.DefaultEffects } }

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
                            text: "close"
                            font.family: Services.Icons.family
                            color: Services.Colors.subtext
                            font.pixelSize: 12
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
