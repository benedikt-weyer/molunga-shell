import QtQuick
import "../../services" as Services

// Compact custom slider with a thick accent track and animated thumb.
Item {
    id: root

    property real from: 0
    property real to: 1
    property real value: 0
    property real stepSize: 0.02
    readonly property real position: Math.max(0, Math.min(1, (value - from) / (to - from)))
    signal moved(real newValue)

    implicitHeight: 28
    activeFocusOnTab: true

    function valueAt(x) {
        const usable = Math.max(1, track.width);
        return from + Math.max(0, Math.min(1, (x - track.x) / usable)) * (to - from);
    }

    function step(delta) {
        moved(Math.max(from, Math.min(to, value + delta * stepSize)));
    }

    Rectangle {
        id: track
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 7
        radius: height / 2
        color: Services.Colors.overlay

        Rectangle {
            width: parent.width * root.position
            height: parent.height
            radius: parent.radius
            color: Services.Colors.accent
        }
    }

    Rectangle {
        id: thumb
        x: track.x + track.width * root.position - width / 2
        anchors.verticalCenter: parent.verticalCenter
        width: pointer.pressed ? 18 : 16
        height: width
        radius: width / 2
        color: Services.Colors.text
        border.width: 3
        border.color: Services.Colors.accent

        Behavior on width { NumberAnimation { duration: 90 } }
        Behavior on x { NumberAnimation { duration: pointer.pressed ? 0 : 70 } }
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        function updateValue(mouse) {
            root.moved(root.valueAt(mouse.x));
        }

        onPressed: mouse => updateValue(mouse)
        onPositionChanged: mouse => { if (pressed) updateValue(mouse); }
        onWheel: wheel => {
            root.step(wheel.angleDelta.y > 0 ? 1 : -1);
            wheel.accepted = true;
        }
    }

    Keys.onLeftPressed: event => { root.step(-1); event.accepted = true; }
    Keys.onRightPressed: event => { root.step(1); event.accepted = true; }
}
