import QtQuick
import "../../services" as Services

// `Behavior on color` preset matching Anim.qml's motion tokens - color
// properties need a ColorAnimation rather than NumberAnimation. Mirrors
// caelestia-shell's components/CAnim.qml.
ColorAnimation {
    duration: Services.Motion.durations.defaultEffects
    easing.type: Easing.BezierSpline
    easing.bezierCurve: Services.Motion.expressiveDefaultEffects
}
