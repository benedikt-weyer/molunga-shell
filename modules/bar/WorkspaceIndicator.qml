import QtQuick
import QtQuick.Layouts
import "../../services" as Services
import "../widgets" as Widgets

// One pill per workspace on this bar's output, filled in when active.
// Backed by Services.Workspaces, which is fed by the compositor's
// ext-workspace-v1 global - see that service's doc comment.
Item {
    id: root

    required property string screenName

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    // Scrolling anywhere over the indicator (not just a pill) steps the
    // active workspace by one, mirroring the compositor's super+mousewheel
    // binding. A plain sibling rather than a Layout child, so it overlays
    // the whole indicator without taking up a slot in `layout`.
    MouseArea {
        anchors.fill: parent
        anchors.margins: -4
        acceptedButtons: Qt.NoButton
        onWheel: wheel => {
            Services.Workspaces.scrollActivate(root.screenName, wheel.angleDelta.y < 0 ? 1 : -1);
        }
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: 4

        Repeater {
            model: Services.Workspaces.forOutput(root.screenName)

            delegate: Rectangle {
                id: pill
                required property var modelData

                Layout.preferredWidth: modelData.active ? 20 : 8
                Layout.preferredHeight: 8
                Layout.alignment: Qt.AlignVCenter
                radius: 4
                color: modelData.active ? Services.Colors.accent : Services.Colors.overlay

                Behavior on Layout.preferredWidth { Widgets.Anim { type: Widgets.Anim.FastSpatial } }
                Behavior on color { Widgets.ColorAnim {} }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.Workspaces.activate(root.screenName, pill.modelData.index)
                }
            }
        }

        // Shown instead of pills when the bridge process isn't running (e.g.
        // the compositor doesn't implement ext-workspace-v1, or the shell is
        // running under some other compositor entirely).
        Text {
            visible: !Services.Workspaces.available
            text: "workspaces unavailable"
            color: Services.Colors.disabled
            font.pixelSize: 11
        }
    }
}
