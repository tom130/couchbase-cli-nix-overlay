{
  description = "Standalone Couchbase Admin Tools overlay for Nixpkgs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem [ "x86_64-linux" "aarch64-darwin" ] (system:
      let
        overlay = import ./overlays/couchbase.nix;
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
      in {
        overlays.default = overlay;
        packages.default = pkgs;
      }
    );
}
