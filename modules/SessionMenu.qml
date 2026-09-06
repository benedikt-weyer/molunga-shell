import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../services" as Services

// Reboot/shutdown/logout, opened from the bar's power icon. Each action
// needs a second click within a few seconds to actually fire (the button
// itself turns into the confirmation) rather than a separate modal dialog,
// since these are hard to undo.
PanelWindow {
    id: root

    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    visible: Services.UiState.sessionMenuOpen

    WlrLayershell.namespace: "molunga-session-menu"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    anchors.top: true
    anchors.right: true
    margins.top: 4
    margins.right: 4
    implicitWidth: 220
    implicitHeight: panel.implicitHeight
    color: "transparent"

    // Which action (if any) is one click away from firing.
    property string pending: ""

    onVisibleChanged: if (!visible) pending = ""

    Timer {
        id: pendingTimeout
        interval: 4000
        onTriggered: root.pending = ""
    }

    function press(id, action) {
        if (root.pending === id) {
            pendingTimeout.stop();
            root.pending = "";
            action();
        } else {
            root.pending = id;
            pendingTimeout.restart();
        }
    }

    component ActionRow: Rectangle {
        id: actionRow
        property string actionId: ""
        property string icon: ""
        property string label: ""
        property color tint: Services.Colors.text
        signal activate()

        readonly property bool isPending: root.pending === actionId

        Layout.fillWidth: true
        implicitHeight: 34
        radius: Services.Colors.radiusSmall
        color: isPending ? Services.Colors.overlay : (hover.hovered ? Services.Colors.surfaceAlt : "transparent")
        Behavior on color { ColorAnimation { duration: 100 } }

        HoverHandler { id: hover }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 8

            Text {
                text: actionRow.icon
                font.pixelSize: 14
                color: actionRow.isPending ? actionRow.tint : Services.Colors.text
            }

            Text {
                Layout.fillWidth: true
                text: actionRow.isPending ? "Confirm " + actionRow.label.toLowerCase() + "?" : actionRow.label
                color: actionRow.isPending ? actionRow.tint : Services.Colors.text
                font.pixelSize: 12
                font.bold: actionRow.isPending
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.press(actionRow.actionId, actionRow.activate)
        }
    }

    Rectangle {
        id: panel
        width: parent.width
        implicitHeight: content.implicitHeight + 12
        radius: Services.Colors.radius
        color: Services.Colors.surface
        border.width: 1
        border.color: Services.Colors.border

        ColumnLayout {
            id: content
            x: 6
            y: 6
            width: parent.width - 12
            spacing: 2

            ActionRow {
                actionId: "logout"
                icon: "⇥"
                label: "Log out"
                tint: Services.Colors.warn
                onActivate: Services.Session.logout()
            }

            ActionRow {
                actionId: "reboot"
                icon: "↻"
                label: "Reboot"
                tint: Services.Colors.warn
                onActivate: Services.Session.reboot()
            }

            ActionRow {
                actionId: "shutdown"
                icon: "⏻"
                label: "Shut down"
                tint: Services.Colors.danger
                onActivate: Services.Session.shutdown()
            }
        }
    }
}
