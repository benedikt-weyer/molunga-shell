//@ pragma UseQApplication
// Tray icons' context menus (TrayWidget.qml's `SystemTrayItem.display()`)
// are native DBusMenu items rendered through Qt's platform menu backend,
// which only exists in QApplication (widgets) mode - without this pragma
// they fail silently at click time with "Cannot display PlatformMenuEntry
// as quickshell was not started in QApplication mode".

//! molunga-shell: a Quickshell configuration built for ironland-compositor.
//!
//! - Bar.qml: per-output top bar (workspace indicator, media widget,
//!   network status, notification bell, clock, settings, session/power
//!   buttons) as a wlr-layer-shell surface - first-class on any wlroots
//!   compositor, ironland-compositor included.
//! - Dock.qml: pinned-app launcher dock.
//! - NotificationPopups.qml / NotificationMenu.qml: toasts and history for
//!   the notification daemon in services/Notifications.qml.
//! - NetworkMenu.qml: wifi/LAN/VPN details, for services/Network.qml and
//!   services/Vpn.qml.
//! - SessionMenu.qml: reboot/shutdown/logout, for services/Session.qml.
//! - SettingsWindow.qml: editor for ironland-compositor's own config.toml.
//!
//! Workspace state comes from the compositor's `ext-workspace-v1` global by
//! way of the `ironland-workspaces` helper - see services/Workspaces.qml.
import Quickshell
import "./modules" as Modules

ShellRoot {
    Modules.Bar {}
    Modules.Dock {}
    Modules.NotificationPopups {}
    Modules.NotificationMenu {}
    Modules.NetworkMenu {}
    Modules.SoundMenu {}
    Modules.SessionMenu {}
    Modules.SettingsWindow {}
}
