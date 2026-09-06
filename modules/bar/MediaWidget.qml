import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import "../../services" as Services

// Compact now-playing control, backed by MPRIS (any player - browsers,
// music apps, etc.) rather than anything compositor-specific.
RowLayout {
    id: root
    spacing: 6
    visible: player !== null

    readonly property var player: {
        const players = Mpris.players.values;
        for (const p of players) if (p.isPlaying) return p;
        return players.length > 0 ? players[0] : null;
    }

    Text {
        Layout.maximumWidth: 220
        elide: Text.ElideRight
        color: Services.Colors.text
        font.pixelSize: 12
        text: root.player ? (root.player.trackArtist ? root.player.trackArtist + " — " + root.player.trackTitle : root.player.trackTitle) : ""
    }

    Text {
        text: "⏮"
        font.pixelSize: 13
        color: root.player && root.player.canGoPrevious ? Services.Colors.text : Services.Colors.disabled
        MouseArea {
            anchors.fill: parent
            anchors.margins: -4
            enabled: root.player && root.player.canGoPrevious
            cursorShape: Qt.PointingHandCursor
            onClicked: root.player.previous()
        }
    }

    Text {
        text: root.player && root.player.isPlaying ? "⏸" : "▶"
        font.pixelSize: 13
        color: root.player && root.player.canTogglePlaying ? Services.Colors.accent : Services.Colors.disabled
        MouseArea {
            anchors.fill: parent
            anchors.margins: -4
            enabled: root.player && root.player.canTogglePlaying
            cursorShape: Qt.PointingHandCursor
            onClicked: root.player.togglePlaying()
        }
    }

    Text {
        text: "⏭"
        font.pixelSize: 13
        color: root.player && root.player.canGoNext ? Services.Colors.text : Services.Colors.disabled
        MouseArea {
            anchors.fill: parent
            anchors.margins: -4
            enabled: root.player && root.player.canGoNext
            cursorShape: Qt.PointingHandCursor
            onClicked: root.player.next()
        }
    }
}
