# Nix Couchbase Admin Tools Overlay

This repository provides a [Nixpkgs overlay][nixpkgs-overlays] that packages the **Couchbase Server Admin Tools** in a way that works on NixOS or other Nix-based systems.

- **Name:** `couchbase-server-admin-tools`
- **Version:** `7.6.4`
- **Derivation file:** [`overlay.nix`](./overlay.nix)

## Overview

The overlay does three things:
1. Fetches the Couchbase Admin Tools tarball from the [Couchbase releases website][couchbase-releases].
2. **Patchelf**s all dynamically-linked binaries, so they work on NixOS.
3. Installs Couchbase CLI tools (`couchbase-cli`, `cbbackupmgr`, etc.) plus embedded libraries and Python into the Nix store.

## Usage (Flakes)

If your own Nix configuration uses flakes, add something like this to your `flake.nix`:

```nix
{
  # ...
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    couchbase-overlay.url = "github:tom130/couchbase-cli-nix-overlay";
  };

  outputs = { self, nixpkgs, couchbase-overlay, ... }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";    # or "aarch64-linux", etc.
        overlays = [
                 couchbase-overlay.overlays.default
               ];
      };
    in
    {
      nixosConfigurations.myMachine = pkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {
            environment.systemPackages = with pkgs; [
              couchbase-server-admin-tools
            ];
          }
        ];
      };
    };
}
```
Then rebuild:

```bash
nixos-rebuild switch --flake .#myMachine
```

When complete, you can run:

```bash
couchbase-cli --version
```

## Usage (Non-Flakes)
If you still maintain a classic configuration.nix (no flake) and want to import this overlay from Git, you can do:

```nix
# /etc/nixos/configuration.nix (or wherever)
{ config, pkgs, ... }:

let
  couchbaseOverlay = import (builtins.fetchGit {
    url = "https://github.com/tom130/couchbase-cli-nix-overlay.git";
    rev = "SOME_COMMIT_SHA_OR_BRANCH";
  });
in {
  nixpkgs.overlays = [
    couchbaseOverlay
  ];

  environment.systemPackages = with pkgs; [
    couchbase-server-admin-tools
  ];
}
```
Then rebuild with:

```bash
sudo nixos-rebuild switch -I nixos-config=/etc/nixos/configuration.nix
```
