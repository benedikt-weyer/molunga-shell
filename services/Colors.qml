pragma Singleton
import QtQuick

// Shared color tokens and small layout constants for every widget. One
// place to retheme the whole shell from.
QtObject {
    readonly property color base: "#12141c"
    readonly property color surface: "#191c26"
    readonly property color surfaceAlt: "#222634"
    readonly property color overlay: "#2b3040"
    readonly property color border: "#333952"

    readonly property color text: "#e6e9f2"
    readonly property color subtext: "#9aa1b8"
    readonly property color disabled: "#5b6178"

    readonly property color accent: "#84dcc6"
    readonly property color accentText: "#0f1712"
    readonly property color danger: "#e88a8a"
    readonly property color warn: "#e3c27e"

    readonly property int radius: 10
    readonly property int radiusSmall: 6
    readonly property int barHeight: 34
    readonly property int spacing: 6
}
