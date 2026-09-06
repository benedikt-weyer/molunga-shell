{
  description = "molunga-shell: a Quickshell configuration for ironland-copositor";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        # Pure QML, so there's nothing to compile - just a wrapper that
        # points `quickshell` at this repo's `shell.qml` regardless of
        # what's on PATH or in $XDG_CONFIG_HOME when it's launched.
        #
        # Launches by *name* (`-c molunga-shell`) rather than by the store
        # path (`-p ${self}/shell.qml`): Quickshell keys a config's state/
        # cache dirs (see `Quickshell.statePath()` in Dock.qml, used to
        # persist dock pins) off how the config was identified, and `-p`
        # identifies it by that literal path. Since `${self}` is a Nix
        # store path, it changes on every rebuild, so `-p` would make each
        # rebuild look like a brand-new, state-less config - resetting
        # pinned dock apps. Keeping a stable `~/.config/quickshell/
        # molunga-shell` symlink (repointed at the current store path on
        # each launch) and running `-c molunga-shell` keeps that identity
        # - and the persisted state - stable across rebuilds.
        packages.default = pkgs.writeShellScriptBin "molunga-shell" ''
          set -euo pipefail
          config_root="''${XDG_CONFIG_HOME:-$HOME/.config}/quickshell"
          mkdir -p "$config_root"
          ln -sfn ${self} "$config_root/molunga-shell"
          exec ${pkgs.quickshell}/bin/quickshell -c molunga-shell "$@"
        '';

        devShells.default = pkgs.mkShell {
          packages = [ pkgs.quickshell ];
        };
      })) // {
      # Runs molunga-shell as a systemd --user service (see nix/module.nix
      # for why: it's what lets a rebuild pick up a new build without a
      # logout).
      nixosModules.default = import ./nix/module.nix;
    };
}
