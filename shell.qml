//! molunga-shell: a Quickshell configuration built for ironland-copositor.
//!
//! - Bar.qml: per-output top bar (workspace indicator, media widget,
//!   network status, notification bell, clock, settings button) as a
//!   wlr-layer-shell surface - first-class on any wlroots compositor,
//!   ironland-copositor included.
//! - Dock.qml: pinned-app launcher dock.
//! - NotificationPopups.qml / NotificationMenu.qml: toasts and history for
//!   the notification daemon in services/Notifications.qml.
//! - NetworkMenu.qml: wifi/LAN/VPN details, for services/Network.qml and
//!   services/Vpn.qml.
//! - SettingsWindow.qml: editor for ironland-copositor's own config.toml.
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
    Modules.SettingsWindow {}
}
