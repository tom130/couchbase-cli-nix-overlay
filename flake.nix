# flake.nix
{
  description = "Standalone Couchbase Admin Tools overlay for Nixpkgs";

  outputs = { self, nixpkgs, ... }:
    let
      supportedSystems = [ "x86_64-linux" ];
    in
    {
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [
          couchbase-overlay.overlays.default
        ];
      };
    }
}
