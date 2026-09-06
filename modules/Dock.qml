pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../services" as Services
import "./widgets" as Widgets

// An application dock, bottom-anchored on the primary screen, with a
// running-apps section fed by the compositor's `wlr-foreign-toplevel-
// management` support (see `Quickshell.Wayland.ToplevelManager`).
//
// Pinned tiles launch via `DesktopEntry.execute()` rather than shelling out
// directly, so apps pick up whatever the .desktop file specifies (Exec
// field, terminal wrapping, etc). ironland-copositor's own configured
// terminal/browser/file manager (see `Services.CompositorConfig`) are
// resolved by heuristic name lookup and used as the initial set of pins on
// first run, ahead of a few fixed extras. Pin changes are saved in
// Quickshell's state directory and loaded back verbatim from then on, so
// they never get overwritten by a re-derived default. Entries that don't
// resolve to an installed app are skipped.
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

    readonly property var defaultPinnedIds: {
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
            const entry = DesktopEntries.byId(id) || DesktopEntries.heuristicLookup(id);
            if (entry && !entry.noDisplay && !seen.has(entry.id)) {
                seen.add(entry.id);
                result.push(entry.id);
            }
        }
        return result;
    }

    readonly property var entries: {
        const result = [];
        for (const id of pinState.pinnedIds ?? []) {
            const entry = DesktopEntries.byId(id) || DesktopEntries.heuristicLookup(id);
            if (entry && !entry.noDisplay) result.push(entry);
        }
        return result;
    }

    function isPinned(entry) {
        return entry && (pinState.pinnedIds ?? []).includes(entry.id);
    }

    function setPinned(entry, pinned) {
        if (!entry) return;
        const ids = [...(pinState.pinnedIds ?? [])];
        const index = ids.indexOf(entry.id);
        if (pinned && index === -1) ids.push(entry.id);
        if (!pinned && index !== -1) ids.splice(index, 1);
        pinState.pinnedIds = ids;
    }

    function openContextMenu(anchorItem, entry, toplevel) {
        appMenu.visible = false;
        appMenu.desktopEntry = entry;
        appMenu.toplevel = toplevel;
        appMenu.anchorItem = anchorItem;
        appMenu.visible = true;
    }

    FileView {
        id: pinFile
        path: Quickshell.statePath("dock-pins.json")
        blockLoading: true
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        // Seed pins from `defaultPinnedIds` only on a genuine first run
        // (no state file yet) - never as `pinnedIds`'s declared default.
        // `defaultPinnedIds` is a live expression (it tracks
        // CompositorConfig's async-resolved terminal/browser/file manager
        // and DesktopEntries lookups), so binding `pinnedIds` to it
        // directly would leave the property "live" until something else
        // overwrites it; any later recompute of `defaultPinnedIds` (e.g.
        // once CompositorConfig or the desktop entry scan catches up) would
        // fire `onAdapterUpdated` and silently persist the new default over
        // whatever the user had actually pinned.
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                pinState.pinnedIds = dock.defaultPinnedIds;
        }

        JsonAdapter {
            id: pinState
            property var pinnedIds: []
        }
    }

    component ContextMenuItem: Rectangle {
        id: menuItem

        required property string label
        property string iconName: ""
        signal selected

        width: 226
        height: 34
        radius: Services.Colors.radiusSmall
        color: menuMouse.containsMouse ? Services.Colors.overlay : "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 9
            anchors.rightMargin: 9
            spacing: 9

            IconImage {
                visible: menuItem.iconName.length > 0
                implicitSize: 16
                source: Quickshell.iconPath(menuItem.iconName, "application-x-executable")
            }

            Text {
                Layout.fillWidth: true
                text: menuItem.label
                color: Services.Colors.text
                font.pixelSize: 13
                elide: Text.ElideRight
            }
        }

        MouseArea {
            id: menuMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: menuItem.selected()
        }
    }

    PopupWindow {
        id: appMenu

        property var desktopEntry: null
        property var toplevel: null
        property Item anchorItem: null

        anchor.item: anchorItem
        anchor.edges: Edges.Top | Edges.Left
        anchor.gravity: Edges.Top | Edges.Right
        anchor.margins.top: 6
        implicitWidth: 238
        implicitHeight: menuColumn.implicitHeight + 12
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: Services.Colors.radius
            color: Services.Colors.surface
            border.color: Services.Colors.border
            border.width: 1

            Column {
                id: menuColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 6

                Text {
                    width: parent.width
                    height: 30
                    leftPadding: 9
                    rightPadding: 9
                    verticalAlignment: Text.AlignVCenter
                    text: appMenu.desktopEntry?.name ?? appMenu.toplevel?.title ?? "Application"
                    color: Services.Colors.text
                    font.bold: true
                    font.pixelSize: 13
                    elide: Text.ElideRight
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Services.Colors.border
                }

                ContextMenuItem {
                    visible: appMenu.desktopEntry !== null
                    label: "Open new window"
                    iconName: appMenu.desktopEntry?.icon ?? ""
                    onSelected: {
                        appMenu.desktopEntry.execute();
                        appMenu.visible = false;
                    }
                }

                Repeater {
                    model: appMenu.desktopEntry?.actions ?? []

                    delegate: ContextMenuItem {
                        required property var modelData
                        label: modelData.name
                        iconName: modelData.icon
                        onSelected: {
                            modelData.execute();
                            appMenu.visible = false;
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    visible: appMenu.desktopEntry !== null
                    color: Services.Colors.border
                }

                ContextMenuItem {
                    visible: appMenu.desktopEntry !== null
                    label: dock.isPinned(appMenu.desktopEntry) ? "Unpin from dock" : "Pin to dock"
                    iconName: dock.isPinned(appMenu.desktopEntry) ? "list-remove" : "list-add"
                    onSelected: {
                        dock.setPinned(appMenu.desktopEntry, !dock.isPinned(appMenu.desktopEntry));
                        appMenu.visible = false;
                    }
                }

                ContextMenuItem {
                    visible: appMenu.toplevel !== null
                    label: "Close window"
                    iconName: "window-close"
                    onSelected: {
                        appMenu.toplevel.close();
                        appMenu.visible = false;
                    }
                }
            }
        }
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

                Behavior on color { Widgets.ColorAnim {} }

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
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton)
                                dock.openContextMenu(pinnedTile, pinnedTile.modelData, null);
                            else
                                pinnedTile.modelData.execute();
                        }
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
                    // `heuristicLookup` fuzzy-matches its argument against
                    // every installed app's name, so calling it with an
                    // empty string (any app that never sets a Wayland
                    // app_id at all - e.g. gui-settings, a Fyne/GLFW app -
                    // reports `appId: ""`, not a name that just fails to
                    // match) matched an essentially arbitrary desktop entry
                    // instead of finding none. Guessing further from the
                    // window title would just trade one wrong-icon guess
                    // for another (a title like "ironland-copositor
                    // Settings" fuzzy-matches plenty of unrelated things
                    // too) - GNOME doesn't try that either, it shows the
                    // generic icon for anything it can't cleanly match, so
                    // an unresolved appId falls straight through to the
                    // IconImage's own fallback below instead.
                    readonly property var desktopEntry:
                        DesktopEntries.byId(modelData.appId)
                        || (modelData.appId ? DesktopEntries.heuristicLookup(modelData.appId) : null)
                    highlighted: modelData.activated

                    IconImage {
                        anchors.centerIn: parent
                        implicitSize: 28
                        // "application-x-executable" is the same generic
                        // fallback icon name GNOME itself uses for
                        // unmatched apps - a gear/cog under any
                        // freedesktop-compliant icon theme (this shell's
                        // Papirus-Dark included).
                        source: Quickshell.iconPath(
                            runningTile.desktopEntry?.icon ?? "",
                            "application-x-executable")
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton)
                                dock.openContextMenu(runningTile, runningTile.desktopEntry, runningTile.modelData);
                            else
                                runningTile.modelData.activate();
                        }
                    }
                }
            }
        }
    }
}
