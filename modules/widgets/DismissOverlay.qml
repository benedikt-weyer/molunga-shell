import QtQuick

// Fills a fullscreen-anchored popup window and requests it close on an
// outside click or Escape. Used by NetworkMenu/NotificationMenu/SessionMenu:
// put this as the *first* child of the window (so it sits behind the actual
// panel), and give the panel its own opaque MouseArea so clicks on it don't
// fall through to this one and immediately dismiss it.
//
// Grabs keyboard focus itself while the window is visible (the window has
// to be told to `forceActiveFocus()` on the caller's side - see
// `WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand` on each popup),
// so Escape works even before anything inside the panel has been clicked.
MouseArea {
    id: root

    anchors.fill: parent
    focus: true

    signal dismissed()

    onClicked: root.dismissed()
    Keys.onEscapePressed: root.dismissed()
}
