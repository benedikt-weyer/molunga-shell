{ config, lib, pkgs, ... }:

let
  cfg = config.services.molunga-shell;
in
{
  options.services.molunga-shell = {
    enable = lib.mkEnableOption "molunga-shell as a systemd --user service";

    package = lib.mkOption {
      type = lib.types.package;
      description = "The molunga-shell package to run.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Not started automatically (no `wantedBy`): systemd --user reaches
    # `default.target` on any login, including a plain SSH one with no
    # Wayland display for this to attach to. It's meant to be started
    # explicitly once a compositor session is actually up - e.g.
    # ironland-copositor's launch script does `systemctl --user start
    # molunga-shell.service` once it knows `WAYLAND_DISPLAY`.
    #
    # That's also what makes a rebuild pick up a new molunga-shell build
    # without needing a logout, with no restart-on-rebuild logic of our
    # own: `nixos-rebuild switch` already restarts any *active* systemd
    # unit whose definition changed, and this one stays active for the
    # life of the session once started.
    systemd.user.services.molunga-shell = {
      description = "molunga-shell (Quickshell) for ironland-copositor";
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/molunga-shell";
        Restart = "on-failure";
        RestartSec = 1;
      };
    };
  };
}
