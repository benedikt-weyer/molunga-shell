import QtQuick
import "../../services" as Services

// A NumberAnimation preset to `Behavior on <property>`, so every widget
// picks a transition off the same Material-3-flavoured motion tokens
// (services/Motion.qml) instead of inventing its own duration/easing.
// Mirrors caelestia-shell's components/Anim.qml.
NumberAnimation {
    id: root

    enum Type {
        Standard,
        Emphasized,
        FastSpatial,
        DefaultSpatial,
        SlowSpatial,
        FastEffects,
        DefaultEffects,
        SlowEffects
    }

    property int type: Anim.DefaultEffects

    duration: {
        switch (root.type) {
        case Anim.FastSpatial: return Services.Motion.durations.fastSpatial;
        case Anim.DefaultSpatial: return Services.Motion.durations.defaultSpatial;
        case Anim.SlowSpatial: return Services.Motion.durations.slowSpatial;
        case Anim.FastEffects: return Services.Motion.durations.fastEffects;
        case Anim.SlowEffects: return Services.Motion.durations.slowEffects;
        case Anim.Standard:
        case Anim.Emphasized:
            return Services.Motion.durations.normal;
        default: return Services.Motion.durations.defaultEffects;
        }
    }
    easing.type: Easing.BezierSpline
    easing.bezierCurve: {
        switch (root.type) {
        case Anim.Emphasized: return Services.Motion.emphasized;
        case Anim.FastSpatial: return Services.Motion.expressiveFastSpatial;
        case Anim.DefaultSpatial: return Services.Motion.expressiveDefaultSpatial;
        case Anim.SlowSpatial: return Services.Motion.expressiveSlowSpatial;
        case Anim.FastEffects: return Services.Motion.expressiveFastEffects;
        case Anim.SlowEffects: return Services.Motion.expressiveSlowEffects;
        case Anim.DefaultEffects: return Services.Motion.expressiveDefaultEffects;
        default: return Services.Motion.standard;
        }
    }
}
