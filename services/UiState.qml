pragma Singleton
import Quickshell

// Cross-window UI toggles: which popups are open. Kept separate from the
// windows themselves since the bar (which triggers these) and the popups
// (which need to know their own visibility) are different top-level
// windows with no parent/child relationship to share state through.
Singleton {
    property bool notificationMenuOpen: false
    property bool networkMenuOpen: false
    property bool settingsOpen: false

    // Both menus anchor to the same top-right corner, so keep at most one
    // open at a time rather than stacking them.
    function toggleNotificationMenu() {
        networkMenuOpen = false;
        notificationMenuOpen = !notificationMenuOpen;
    }

    function toggleNetworkMenu() {
        notificationMenuOpen = false;
        networkMenuOpen = !networkMenuOpen;
    }
}
