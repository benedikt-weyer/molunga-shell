import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../services" as Services

// A pinned-app launcher dock, bottom-anchored on the primary screen, with a
// running-apps section fed by the compositor's `wlr-foreign-toplevel-
// management` support (see `Quickshell.Wayland.ToplevelManager`).
//
// Pinned tiles launch via `DesktopEntry.execute()` rather than shelling out
// directly, so apps pick up whatever the .desktop file specifies (Exec
// field, terminal wrapping, etc). ironland-copositor's own configured
// terminal/browser/file manager (see `Services.CompositorConfig`) are
// resolved by heuristic name lookup and pinned automatically, ahead of a
// few fixed extras; entries that don't resolve to an installed app are
// just skipped rather than shown broken.
//
// Running tiles are one per toplevel (so an app with two windows gets two
// tiles), clicking one activates that specific window, and the currently
// focused window's tile is highlighted - `Toplevel.activated` is exactly
// the compositor's `Activated` state from the protocol, kept in sync with
// keyboard focus.
PanelWindow {
    id: dock

    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null

    WlrLayershell.namespace: "molunga-dock"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    anchors.bottom: true
    implicitWidth: row.implicitWidth + 16
    implicitHeight: 52
    color: "transparent"

    readonly property var extraPinned: ["ironland-copositor-settings"]

    readonly property var runningToplevels: ToplevelManager.toplevels

    readonly property var entries: {
        const ids = [
            Services.CompositorConfig.terminal,
            Services.CompositorConfig.browser,
            Services.CompositorConfig.fileManager,
            ...extraPinned,
        ];
        const seen = new Set();
        const result = [];
        for (const id of ids) {
            if (!id || seen.has(id)) continue;
            seen.add(id);
            const entry = DesktopEntries.byId(id) || DesktopEntries.heuristicLookup(id);
            if (entry && !entry.noDisplay) result.push(entry);
        }
        return result;
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 6
        radius: Services.Colors.radius
        color: Services.Colors.surface
        border.color: Services.Colors.border
        border.width: 1

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 6

            component DockTile: Rectangle {
                id: tile

                property bool highlighted: false

                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                radius: Services.Colors.radiusSmall
                color: hover.hovered ? Services.Colors.overlay : "transparent"
                border.color: tile.highlighted ? Services.Colors.accent : "transparent"
                border.width: 2

                Behavior on color { ColorAnimation { duration: 100 } }

                HoverHandler { id: hover }
            }

            Repeater {
                model: dock.entries

                delegate: DockTile {
                    id: pinnedTile
                    required property var modelData

                    IconImage {
                        anchors.centerIn: parent
                        implicitSize: 28
                        source: Quickshell.iconPath(pinnedTile.modelData.icon, "application-x-executable")
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: pinnedTile.modelData.execute()
                    }
                }
            }

            Rectangle {
                visible: dock.entries.length > 0 && dock.runningToplevels.values.length > 0
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                Layout.topMargin: 8
                Layout.bottomMargin: 8
                color: Services.Colors.border
            }

            Repeater {
                model: dock.runningToplevels

                delegate: DockTile {
                    id: runningTile
                    required property var modelData
                    highlighted: modelData.activated

                    IconImage {
                        anchors.centerIn: parent
                        implicitSize: 28
                        source: Quickshell.iconPath(
                            DesktopEntries.heuristicLookup(runningTile.modelData.appId)?.icon ?? "",
                            "application-x-executable")
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: runningTile.modelData.activate()
                    }
                }
            }
        }
    }
}
