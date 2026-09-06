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
        packages.default = pkgs.writeShellScriptBin "molunga-shell" ''
          exec ${pkgs.quickshell}/bin/quickshell -p ${self}/shell.qml "$@"
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
