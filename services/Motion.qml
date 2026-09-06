pragma Singleton
import QtQuick

// Material 3 expressive motion tokens - durations and cubic-bezier easing
// curves - so widgets share one consistent, springy feel instead of each
// picking its own ad-hoc duration/easing. Ported from the curve/duration
// values caelestia-shell bakes into its native config plugin
// (plugin/src/Caelestia/Config/tokens.hpp); this is the plain-QML
// equivalent, with no config layer of its own.
//
// Use via Behavior { NumberAnimation { duration: Services.Motion.durations.x
// easing.type: Easing.BezierSpline; easing.bezierCurve: Services.Motion.y } },
// or more conveniently through Widgets.Anim/Widgets.ColorAnim, which wrap
// exactly that.
QtObject {
    readonly property QtObject durations: QtObject {
        readonly property int small: 200
        readonly property int normal: 400
        readonly property int large: 600
        readonly property int extraLarge: 1000
        readonly property int fastSpatial: 350
        readonly property int defaultSpatial: 500
        readonly property int slowSpatial: 650
        readonly property int fastEffects: 150
        readonly property int defaultEffects: 200
        readonly property int slowEffects: 300
    }

    // Standard: subtle, utilitarian transitions (size/position tweaks).
    readonly property var standard: [0.2, 0, 0, 1, 1, 1]
    readonly property var standardAccel: [0.3, 0, 1, 1, 1, 1]
    readonly property var standardDecel: [0, 0, 0, 1, 1, 1]

    // Emphasized: more pronounced overshoot, for things drawing attention.
    readonly property var emphasized: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
    readonly property var emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
    readonly property var emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]

    // Expressive spatial: movement/resizing that should feel lively.
    readonly property var expressiveFastSpatial: [0.42, 1.67, 0.21, 0.9, 1, 1]
    readonly property var expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1, 1, 1]
    readonly property var expressiveSlowSpatial: [0.39, 1.29, 0.35, 0.98, 1, 1]

    // Expressive effects: opacity/color fades.
    readonly property var expressiveFastEffects: [0.31, 0.94, 0.34, 1, 1, 1]
    readonly property var expressiveDefaultEffects: [0.34, 0.8, 0.34, 1, 1, 1]
    readonly property var expressiveSlowEffects: [0.34, 0.88, 0.34, 1, 1, 1]
}
