import QtQuick
import QtQuick.Layouts
import "../../services" as Services

// One pill per workspace on this bar's output, filled in when active.
// Backed by Services.Workspaces, which is fed by the compositor's
// ext-workspace-v1 global - see that service's doc comment.
RowLayout {
    id: root

    required property string screenName

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

            Behavior on Layout.preferredWidth { NumberAnimation { duration: 120 } }
            Behavior on color { ColorAnimation { duration: 120 } }

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
