pragma Singleton
import Quickshell

// Power actions, via systemd/logind (systemctl/loginctl already go over
// D-Bus to logind themselves, so there's no need to talk to
// org.freedesktop.login1.Manager directly). Needs polkit running to
// authorize poweroff/reboot for the active session - see
// ironland-compositor's flake.nix, which enables it for exactly this.
Singleton {
    function shutdown() {
        Quickshell.execDetached(["systemctl", "poweroff"]);
    }

    function reboot() {
        Quickshell.execDetached(["systemctl", "reboot"]);
    }

    function logout() {
        const sessionId = Quickshell.env("XDG_SESSION_ID");
        if (sessionId) {
            Quickshell.execDetached(["loginctl", "terminate-session", String(sessionId)]);
        } else {
            // Fallback for the (unusual) case where XDG_SESSION_ID isn't
            // set: end every session for the current user instead of one
            // specific session.
            Quickshell.execDetached(["loginctl", "terminate-user", String(Quickshell.env("USER"))]);
        }
    }
}
