import QtQuick
import "../../services" as Services

// The card a dropdown menu (NetworkMenu, SoundMenu, SessionMenu,
// NotificationMenu, ...) puts its content in. Growing it open from its
// anchor corner - rather than snapping straight to fully visible - is the
// one bit of caelestia-shell's drawer choreography that translates cleanly
// to this shell's one-PanelWindow-per-menu setup.
//
// The panel's window should stay mapped for the closing animation too:
// bind its `visible` to `menuOpen || panel.animating`, not just the
// open/closed flag.
Rectangle {
    id: root

    // Drive this from the menu's own open/closed state.
    property bool open: false
    // Corner the panel grows from/into - defaults to top-right, since
    // every dropdown here hangs off the bar's right side.
    property real originX: width
    property real originY: 0
    readonly property bool animating: fade.running || grow.running

    radius: Services.Colors.radius
    color: Services.Colors.surface
    border.width: 1
    border.color: Services.Colors.border

    opacity: open ? 1 : 0
    Behavior on opacity {
        Anim {
            id: fade
            type: root.open ? Anim.FastEffects : Anim.DefaultEffects
        }
    }

    transform: Scale {
        origin.x: root.originX
        origin.y: root.originY
        xScale: 1
        yScale: root.open ? 1 : 0.85

        Behavior on yScale {
            Anim {
                id: grow
                type: root.open ? Anim.DefaultSpatial : Anim.FastSpatial
            }
        }
    }
}
