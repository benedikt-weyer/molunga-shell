import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "./bar" as BarParts
import "../services" as Services

// The top bar: one instance per connected output, each a wlr-layer-shell
// surface anchored to that output's top edge (first-class on
// ironland-copositor, which - like any wlroots compositor - reserves
// screen space for an exclusive-zone layer surface automatically, so
// windows tile around it without the compositor needing to know anything
// about this shell specifically).
Variants {
    model: Quickshell.screens

    PanelWindow {
        id: bar
        required property ShellScreen modelData
        screen: modelData

        WlrLayershell.namespace: "molunga-bar"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.exclusionMode: ExclusionMode.Auto

        anchors.top: true
        anchors.left: true
        anchors.right: true
        implicitHeight: Services.Colors.barHeight
        color: Services.Colors.base

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 14

            BarParts.WorkspaceIndicator {
                screenName: bar.modelData.name
            }

            Item { Layout.fillWidth: true }

            BarParts.MediaWidget {}

            BarParts.SoundWidget {}

            BarParts.NetworkWidget {}

            BarParts.NotificationButton {}

            BarParts.ClockWidget {}

            BarParts.SettingsButton {}

            BarParts.SessionButton {}
        }
    }
}
