import Quickshell
import QtQuick
import QtQuick.Layouts
import "../services" as Services
import "./widgets" as Widgets

// Editor for ironland-compositor's own config.toml (terminal/browser/file
// manager, top bar, workspace layout) - see Services.CompositorConfig for
// how it's read back and patched. Not layer-shell: a normal floating
// window, since a settings dialog has no business reserving screen space
// or sitting above everything else.
FloatingWindow {
    id: window

    visible: Services.UiState.settingsOpen
    title: "molunga-shell settings"
    implicitWidth: 420
    implicitHeight: content.implicitHeight + 32
    color: Services.Colors.base

    onVisibleChanged: if (visible) { Services.CompositorConfig.reload(); content.forceActiveFocus(); }

    // --- small reusable pieces ------------------------------------------

    component SectionLabel: Text {
        Layout.topMargin: 10
        color: Services.Colors.subtext
        font.pixelSize: 11
        font.bold: true
    }

    component FieldRow: RowLayout {
        Layout.fillWidth: true
        property alias label: labelText.text
        default property alias content: slot.data

        Text {
            id: labelText
            Layout.preferredWidth: 120
            color: Services.Colors.text
            font.pixelSize: 12
        }

        RowLayout {
            id: slot
            Layout.fillWidth: true
        }
    }

    component TextField: Rectangle {
        id: field
        property alias text: input.text
        signal editingFinished()

        Layout.fillWidth: true
        implicitHeight: 26
        radius: Services.Colors.radiusSmall
        color: Services.Colors.surfaceAlt
        border.width: 1
        border.color: input.activeFocus ? Services.Colors.accent : Services.Colors.border

        TextInput {
            id: input
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            verticalAlignment: TextInput.AlignVCenter
            color: Services.Colors.text
            font.pixelSize: 12
            clip: true
            onEditingFinished: field.editingFinished()
        }
    }

    component PillOption: Rectangle {
        id: pill
        property bool selected: false
        property string label: ""
        // When set, `label` is a Material Symbols name (e.g. "add") rather
        // than plain text.
        property bool icon: false
        signal picked()

        implicitWidth: pillText.implicitWidth + 16
        implicitHeight: 24
        radius: 12
        color: selected ? Services.Colors.accent : Services.Colors.surfaceAlt
        border.width: 1
        border.color: Services.Colors.border

        Text {
            id: pillText
            anchors.centerIn: parent
            text: pill.label
            font.family: pill.icon ? Services.Icons.family : ""
            font.pixelSize: pill.icon ? 13 : 11
            color: pill.selected ? Services.Colors.accentText : Services.Colors.text
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: pill.picked()
        }
    }

    // --- layout ------------------------------------------------------------

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 16
        spacing: 8
        focus: true
        Keys.onEscapePressed: Services.UiState.settingsOpen = false

        RowLayout {
            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true
                text: "molunga-shell settings"
                color: Services.Colors.text
                font.pixelSize: 15
                font.bold: true
            }

            Text {
                text: "close"
                font.family: Services.Icons.family
                color: Services.Colors.subtext
                font.pixelSize: 15
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.UiState.settingsOpen = false
                }
            }
        }

        Text {
            text: "General"
            color: Services.Colors.text
            font.pixelSize: 14
            font.bold: true
        }

        FieldRow {
            label: "Terminal"
            TextField {
                text: Services.CompositorConfig.terminal
                onEditingFinished: Services.CompositorConfig.terminal = text
            }
        }

        FieldRow {
            label: "Browser"
            TextField {
                text: Services.CompositorConfig.browser
                onEditingFinished: Services.CompositorConfig.browser = text
            }
        }

        FieldRow {
            label: "File manager"
            TextField {
                text: Services.CompositorConfig.fileManager
                onEditingFinished: Services.CompositorConfig.fileManager = text
            }
        }

        FieldRow {
            label: "Server-side title bars"
            Widgets.ToggleSwitch {
                checked: Services.CompositorConfig.topBar
                onToggled: Services.CompositorConfig.topBar = !Services.CompositorConfig.topBar
            }
        }

        SectionLabel { text: "WORKSPACES" }

        FieldRow {
            label: "Mode"
            PillOption {
                label: "Per monitor"
                selected: Services.CompositorConfig.workspaceMode === "per_monitor"
                onPicked: Services.CompositorConfig.workspaceMode = "per_monitor"
            }
            PillOption {
                label: "Combined"
                selected: Services.CompositorConfig.workspaceMode === "combined"
                onPicked: Services.CompositorConfig.workspaceMode = "combined"
            }
        }

        FieldRow {
            label: "Count"
            PillOption {
                label: "remove"
                icon: true
                onPicked: Services.CompositorConfig.workspaceCount = Math.max(1, Services.CompositorConfig.workspaceCount - 1)
            }
            Text {
                text: Services.CompositorConfig.workspaceCount
                color: Services.Colors.text
                font.pixelSize: 12
                Layout.preferredWidth: 20
                horizontalAlignment: Text.AlignHCenter
            }
            PillOption {
                label: "add"
                icon: true
                onPicked: Services.CompositorConfig.workspaceCount = Services.CompositorConfig.workspaceCount + 1
            }
        }

        FieldRow {
            label: "Dynamic (grow/prune)"
            Widgets.ToggleSwitch {
                checked: Services.CompositorConfig.workspaceDynamic
                onToggled: Services.CompositorConfig.workspaceDynamic = !Services.CompositorConfig.workspaceDynamic
            }
        }

        FieldRow {
            label: "Switch overlay"
            Widgets.ToggleSwitch {
                checked: Services.CompositorConfig.workspaceOverlay
                onToggled: Services.CompositorConfig.workspaceOverlay = !Services.CompositorConfig.workspaceOverlay
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 12
            spacing: 8

            Text {
                Layout.fillWidth: true
                text: "Applies on the next compositor restart."
                color: Services.Colors.disabled
                font.pixelSize: 10
            }

            Rectangle {
                implicitWidth: saveText.implicitWidth + 24
                implicitHeight: 28
                radius: Services.Colors.radiusSmall
                color: Services.Colors.accent

                Text {
                    id: saveText
                    anchors.centerIn: parent
                    text: "Save"
                    color: Services.Colors.accentText
                    font.pixelSize: 12
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.CompositorConfig.save()
                }
            }
        }
    }
}
