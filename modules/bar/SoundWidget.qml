import QtQuick
import QtQuick.Layouts
import "../../services" as Services

// Compact output status. Click for full input/output controls; scroll to
// adjust the current output without opening the panel.
Item {
    id: root
    implicitWidth: row.implicitWidth + 8
    implicitHeight: row.implicitHeight

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 5

        Text {
            text: {
                if (!Services.Audio.outputDevice || Services.Audio.outputMuted) return "volume_off";
                if (Services.Audio.outputVolume < 0.34) return "volume_mute";
                if (Services.Audio.outputVolume < 0.67) return "volume_down";
                return "volume_up";
            }
            font.family: Services.Icons.family
            color: Services.UiState.soundMenuOpen ? Services.Colors.accent : Services.Colors.text
            font.pixelSize: 15
        }

        Text {
            text: Services.Audio.outputDevice ? Math.round(Services.Audio.outputVolume * 100) + "%" : "no audio"
            color: Services.UiState.soundMenuOpen ? Services.Colors.accent : Services.Colors.subtext
            font.pixelSize: 11
        }
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -4
        cursorShape: Qt.PointingHandCursor
        onClicked: Services.UiState.toggleSoundMenu()
        onWheel: wheel => {
            const delta = wheel.angleDelta.y > 0 ? 0.03 : -0.03;
            Services.Audio.setOutputVolume(Services.Audio.outputVolume + delta);
            wheel.accepted = true;
        }
    }
}
