{
  description = "Standalone Couchbase Admin Tools overlay for Nixpkgs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    # Make sure the couchbase overlay is available either as an input or via another mechanism.
    couchbase-overlay.url = "path:./overlays/couchbase.nix";
  };

  outputs = { self, nixpkgs, flake-utils, couchbase-overlay, ... }:
    flake-utils.lib.eachDefaultSystem [ "x86_64-linux" "aarch64-darwin" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ couchbase-overlay.overlays.default ];
        };
      in {
        packages.default = pkgs;
      }
    );
}
