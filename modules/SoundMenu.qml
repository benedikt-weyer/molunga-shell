pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../services" as Services
import "./widgets" as Widgets

// Sound device selection and volume controls, opened from the bar.
PanelWindow {
    id: root

    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    visible: Services.UiState.soundMenuOpen

    WlrLayershell.namespace: "molunga-sound-menu"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    anchors.top: true
    anchors.right: true
    anchors.bottom: true
    anchors.left: true
    color: "transparent"

    property bool outputPickerOpen: false
    property bool inputPickerOpen: false

    onVisibleChanged: {
        if (visible) dismissOverlay.forceActiveFocus();
        else {
            outputPickerOpen = false;
            inputPickerOpen = false;
        }
    }

    Widgets.DismissOverlay {
        id: dismissOverlay
        onDismissed: Services.UiState.soundMenuOpen = false
    }

    component DeviceRow: Rectangle {
        id: deviceRow

        required property var device
        required property bool selected
        signal chosen

        Layout.fillWidth: true
        implicitHeight: 34
        radius: Services.Colors.radiusSmall
        color: selected ? Services.Colors.overlay : (hover.hovered ? Services.Colors.surfaceAlt : "transparent")
        border.width: selected ? 1 : 0
        border.color: Services.Colors.accent

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 9
            anchors.rightMargin: 9

            Text {
                Layout.fillWidth: true
                text: Services.Audio.label(deviceRow.device)
                color: Services.Colors.text
                font.pixelSize: 11
                elide: Text.ElideRight
            }
            Text {
                visible: deviceRow.selected
                text: "check"
                font.family: Services.Icons.family
                font.pixelSize: 13
                color: Services.Colors.accent
            }
        }

        HoverHandler { id: hover }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: deviceRow.chosen()
        }
    }

    component VolumeSection: ColumnLayout {
        id: section

        required property string title
        required property string glyph
        required property var device
        required property var devices
        required property real volume
        required property bool muted
        required property bool pickerOpen
        property var selectDevice
        property var setVolume
        property var toggleMute
        signal pickerToggled

        Layout.fillWidth: true
        spacing: 8

        Text {
            text: section.title
            color: Services.Colors.text
            font.pixelSize: 13
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 42
            radius: Services.Colors.radiusSmall
            color: Services.Colors.surfaceAlt
            border.width: 1
            border.color: section.pickerOpen ? Services.Colors.accent : Services.Colors.border

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Text {
                    text: section.glyph
                    font.family: Services.Icons.family
                    color: section.device ? Services.Colors.accent : Services.Colors.disabled
                    font.pixelSize: 17
                }
                Text {
                    Layout.fillWidth: true
                    text: Services.Audio.label(section.device)
                    color: section.device ? Services.Colors.text : Services.Colors.disabled
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
                Text {
                    text: section.pickerOpen ? "expand_less" : "expand_more"
                    font.family: Services.Icons.family
                    color: Services.Colors.subtext
                    font.pixelSize: 15
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: section.pickerToggled()
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: section.pickerOpen
            spacing: 3

            Repeater {
                model: section.devices

                delegate: DeviceRow {
                    required property var modelData
                    device: modelData
                    selected: modelData === section.device
                    onChosen: section.selectDevice(modelData)
                }
            }

            Text {
                visible: section.devices.length === 0
                text: "No devices found"
                color: Services.Colors.disabled
                font.pixelSize: 11
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                implicitWidth: 34
                implicitHeight: 30
                radius: Services.Colors.radiusSmall
                color: muteMouse.containsMouse ? Services.Colors.overlay : Services.Colors.surfaceAlt
                border.width: 1
                border.color: section.muted ? Services.Colors.danger : Services.Colors.border

                Text {
                    anchors.centerIn: parent
                    text: section.muted ? "volume_off" : section.glyph
                    font.family: Services.Icons.family
                    color: section.muted ? Services.Colors.danger : Services.Colors.text
                    font.pixelSize: 15
                }

                MouseArea {
                    id: muteMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: section.device !== null
                    cursorShape: Qt.PointingHandCursor
                    onClicked: section.toggleMute()
                }
            }

            Widgets.ModernSlider {
                Layout.fillWidth: true
                enabled: section.device !== null
                opacity: enabled ? 1 : 0.4
                from: 0
                to: 1.5
                value: section.volume
                onMoved: newValue => section.setVolume(newValue)
            }

            Text {
                Layout.preferredWidth: 42
                horizontalAlignment: Text.AlignRight
                text: Math.round(section.volume * 100) + "%"
                color: section.muted ? Services.Colors.disabled : Services.Colors.text
                font.pixelSize: 11
                font.family: "monospace"
            }
        }
    }

    Rectangle {
        id: panel
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 4
        width: 370
        implicitHeight: content.implicitHeight
        radius: Services.Colors.radius
        color: Services.Colors.surface
        border.width: 1
        border.color: Services.Colors.border

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            id: content
            width: parent.width
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 14
                Layout.rightMargin: 14
                Layout.topMargin: 12

                Text {
                    Layout.fillWidth: true
                    text: "Sound"
                    color: Services.Colors.text
                    font.pixelSize: 15
                    font.bold: true
                }
                Text {
                    text: Services.Audio.ready ? "PipeWire" : "connecting…"
                    color: Services.Audio.ready ? Services.Colors.accent : Services.Colors.disabled
                    font.pixelSize: 10
                }
            }

            VolumeSection {
                Layout.leftMargin: 14
                Layout.rightMargin: 14
                title: "Output"
                glyph: "volume_up"
                device: Services.Audio.outputDevice
                devices: Services.Audio.outputDevices
                volume: Services.Audio.outputVolume
                muted: Services.Audio.outputMuted
                pickerOpen: root.outputPickerOpen
                selectDevice: node => {
                    Services.Audio.selectOutput(node);
                    root.outputPickerOpen = false;
                }
                setVolume: value => Services.Audio.setOutputVolume(value)
                toggleMute: () => Services.Audio.toggleOutputMute()
                onPickerToggled: {
                    root.outputPickerOpen = !root.outputPickerOpen;
                    root.inputPickerOpen = false;
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 14
                Layout.rightMargin: 14
                implicitHeight: 1
                color: Services.Colors.border
            }

            VolumeSection {
                Layout.leftMargin: 14
                Layout.rightMargin: 14
                Layout.bottomMargin: 14
                title: "Input"
                glyph: "mic"
                device: Services.Audio.inputDevice
                devices: Services.Audio.inputDevices
                volume: Services.Audio.inputVolume
                muted: Services.Audio.inputMuted
                pickerOpen: root.inputPickerOpen
                selectDevice: node => {
                    Services.Audio.selectInput(node);
                    root.inputPickerOpen = false;
                }
                setVolume: value => Services.Audio.setInputVolume(value)
                toggleMute: () => Services.Audio.toggleInputMute()
                onPickerToggled: {
                    root.inputPickerOpen = !root.inputPickerOpen;
                    root.outputPickerOpen = false;
                }
            }
        }
    }
}
