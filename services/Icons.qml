pragma Singleton
import QtQuick

// Material Symbols (Outlined), bundled in assets/ rather than relied on from
// the system font set - a shell shouldn't depend on whatever happens to be
// installed system-wide for its own chrome. Icons are drawn as ligature
// text: put the symbol's name (e.g. "settings", "close") in a Text with
// `font.family: Services.Icons.family`, and Qt's text shaping substitutes
// the glyph via the font's own `liga`/`calt` tables - the same mechanism
// Google's own web usage of this font relies on.
//
// Full names: https://fonts.google.com/icons
QtObject {
    readonly property string family: loader.name

    property FontLoader loader: FontLoader {
        source: "../assets/MaterialSymbolsOutlined.ttf"
    }
}
