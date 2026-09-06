import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../services" as Services

// A pinned-app launcher dock, bottom-anchored on the primary screen.
//
// It launches via `DesktopEntry.execute()` rather than shelling out
// directly, so apps pick up whatever the .desktop file specifies (Exec
// field, terminal wrapping, etc). ironland-copositor's own configured
// terminal/browser/file manager (see `Services.CompositorConfig`) are
// resolved by heuristic name lookup and pinned automatically, ahead of a
// few fixed extras; entries that don't resolve to an installed app are
// just skipped rather than shown broken.
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

            Repeater {
                model: dock.entries

                delegate: Rectangle {
                    id: iconTile
                    required property var modelData

                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    radius: Services.Colors.radiusSmall
                    color: hover.hovered ? Services.Colors.overlay : "transparent"

                    Behavior on color { ColorAnimation { duration: 100 } }

                    IconImage {
                        anchors.centerIn: parent
                        implicitSize: 28
                        source: Quickshell.iconPath(iconTile.modelData.icon, "application-x-executable")
                    }

                    HoverHandler { id: hover }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: iconTile.modelData.execute()
                    }
                }
            }
        }
    }
}
