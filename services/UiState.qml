pragma Singleton
import Quickshell

// Cross-window UI toggles: which popups are open. Kept separate from the
// windows themselves since the bar (which triggers these) and the popups
// (which need to know their own visibility) are different top-level
// windows with no parent/child relationship to share state through.
Singleton {
    property bool notificationMenuOpen: false
    property bool settingsOpen: false

    function toggleNotificationMenu() {
        notificationMenuOpen = !notificationMenuOpen;
    }
}
