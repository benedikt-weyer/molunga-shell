# molunga-shell

A [Quickshell](https://quickshell.org) configuration for
[ironland-copositor](../ironland-copositor). Provides a top bar (workspace
indicator, media widget, wifi/LAN/VPN status, notification bell, clock,
sound input/output controls, settings and session/power buttons), an
application dock, and a notification/settings UI.

## Running

```sh
scripts/run
```

(with direnv: just `run`, once `.envrc` has put `scripts/` on `PATH`). This
is a thin wrapper around `quickshell -p ./shell.qml` that also warns if
`ironland-workspaces` isn't on `PATH`.

Equivalently, run `quickshell -p /path/to/molunga-shell/shell.qml` directly,
or symlink this directory into `~/.config/quickshell/molunga-shell` and run
`quickshell -c molunga-shell`.

The workspace indicator needs the `ironland-workspaces` helper (built
alongside `ironland-copositor` itself - see its `Cargo.toml`) on `PATH`; the
rest of the shell works against any wlr-layer-shell compositor.

## Layout

- `shell.qml` - entry point, instantiates everything below.
- `modules/Bar.qml` - per-output top bar.
- `modules/bar/*` - the bar's individual widgets.
- `modules/Dock.qml` - application dock with persistent pins, running apps,
  and right-click desktop-entry actions.
- `modules/NotificationPopups.qml`, `modules/NotificationMenu.qml` - toasts
  and notification history.
- `modules/NetworkMenu.qml` - wifi/LAN/VPN details and controls.
- `modules/SoundMenu.qml` - output/input device selection, mute controls,
  and volume sliders.
- `modules/SessionMenu.qml` - reboot/shutdown/log out.
- `modules/SettingsWindow.qml` - editor for ironland-copositor's
  `config.toml`.
- `modules/widgets/*` - small reusable pieces (e.g. `ToggleSwitch`) shared
  across the modules above.
- `services/*` - singletons: theme tokens, and the
  workspace/notification/network/audio/config state each widget above reads from.

## Workspace protocol

`services/Workspaces.qml` doesn't talk Wayland directly - Quickshell has no
built-in support for `ext-workspace-v1` - it shells out to
`ironland-workspaces`, a small companion Wayland client (in the compositor
repo) that bridges that protocol to line-delimited JSON on stdin/stdout. See
that binary's module doc for the wire format.

Wifi/LAN status (`services/Network.qml`) is the exception to all of the
above: it's compositor-agnostic (talks to NetworkManager over D-Bus, not to
ironland-copositor), so it uses Quickshell's own `Quickshell.Networking`
module directly, no bridging needed. VPN (`services/Vpn.qml`) needs a
little more, since NetworkManager's VPN connection profiles aren't part of
that module: it polls `nmcli` every few seconds instead.
