# molunga-shell

A [Quickshell](https://quickshell.org) configuration for
[ironland-copositor](../ironland-copositor). Provides a top bar (workspace
indicator, media widget, notification bell, clock, settings button), an
application dock, and a notification/settings UI.

## Running

```sh
quickshell -p /path/to/molunga-shell/shell.qml
```

or symlink this directory into `~/.config/quickshell/molunga-shell` and run
`quickshell -c molunga-shell`.

The workspace indicator needs the `ironland-workspaces` helper (built
alongside `ironland-copositor` itself - see its `Cargo.toml`) on `PATH`; the
rest of the shell works against any wlr-layer-shell compositor.

## Layout

- `shell.qml` - entry point, instantiates everything below.
- `modules/Bar.qml` - per-output top bar.
- `modules/bar/*` - the bar's individual widgets.
- `modules/Dock.qml` - pinned-app launcher dock.
- `modules/NotificationPopups.qml`, `modules/NotificationMenu.qml` - toasts
  and notification history.
- `modules/SettingsWindow.qml` - editor for ironland-copositor's
  `config.toml`.
- `services/*` - singletons: theme tokens, the workspace/notification/config
  state each widget above reads from.

## Workspace protocol

`services/Workspaces.qml` doesn't talk Wayland directly - Quickshell has no
built-in support for `ext-workspace-v1` - it shells out to
`ironland-workspaces`, a small companion Wayland client (in the compositor
repo) that bridges that protocol to line-delimited JSON on stdin/stdout. See
that binary's module doc for the wire format.
