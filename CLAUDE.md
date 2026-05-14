# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal Nix flake declaring a full system configuration for **macOS (via nix-darwin)** and **NixOS** for the single user `ksanteen`. There is one Darwin host (`macos`, aarch64) and NixOS configurations generated per system in `linuxSystems` (`x86_64-linux`, `aarch64-linux`). The flake also wires up Homebrew (via `nix-homebrew`), home-manager, disko, and a few custom inputs (`onyxvim`, `yazi`, `claude-code`).

Currently tracking `nixpkgs/nixos-unstable` (the `25.11` line is commented out in `flake.nix`).

## Common commands

The `apps/<system>/` scripts are the standard entry points. Invoke them either directly or via `nix run`.

```sh
# macOS — build + activate (requires sudo, set NIXPKGS_ALLOW_UNFREE=1)
nix run .#build-switch          # or: ./apps/aarch64-darwin/build-switch
nix run .#build                 # build only, no activation

# NixOS — build + activate (sudo is invoked internally; SSH agent is forwarded)
nix run .#build-switch          # picks x86_64-linux or aarch64-linux from uname -m

# First-time setup on a fresh checkout: substitutes %USER%/%EMAIL%/%NAME%
# (and %INTERFACE%/%DISK%/%HOST% on NixOS) inline across the tree.
# Destructive to the working copy — do NOT run on a configured checkout.
nix run .#apply
```

There is no test suite, linter, or formatter wired up. To sanity-check changes without activating:

```sh
nix --experimental-features 'nix-command flakes' build .#darwinConfigurations.macos.system
nix --experimental-features 'nix-command flakes' build .#nixosConfigurations.nixos-x86_64-linux.config.system.build.toplevel
```

The `devShells.default` (entered via `nix develop`) only provides `bashInteractive` + `git` and sets `EDITOR=vim` — it is not a dev environment for any application code, just a clean shell for working on the flake.

## Architecture

### Host → module composition

```
flake.nix
  ├── darwinConfigurations.macos       → hosts/darwin/default.nix
  └── nixosConfigurations.nixos-<sys>  → hosts/nixos/default.nix

hosts/darwin/default.nix    imports → modules/darwin/home-manager.nix
                                      modules/shared
                                      modules/shared/cachix
hosts/nixos/default.nix     imports → modules/nixos/hardware-configuration.nix
                                      modules/shared
                                      modules/shared/cachix
```

`modules/shared` is where most cross-platform config lives (zsh/fish, tmux, yazi, git, the shared package list). Each of `modules/{darwin,nixos}` adds its own `home-manager.nix`, `files.nix`, and `packages.nix` and merges shared content via `lib.mkMerge` / list concatenation. Darwin additionally has `casks.nix` (Homebrew casks) and a `dock/` module that declaratively manages the macOS Dock.

### Where to put a change

- **A CLI tool that should exist on both macOS and NixOS** → `modules/shared/packages.nix`.
- **A macOS-only GUI app from Homebrew** → `modules/darwin/casks.nix`.
- **A macOS-only nixpkg** → `modules/darwin/packages.nix`.
- **A NixOS-only package or system service** → `modules/nixos/packages.nix` or `hosts/nixos/default.nix`.
- **A dotfile that should be symlinked into `$HOME`** → drop the source into `files/<scope>/`, then register it in the matching `modules/<scope>/files.nix`. Files are managed via home-manager's `home.file` and are immutable in `$HOME`.
- **An nixpkgs override / patch** → add an overlay file under `overlays/` (auto-discovery is currently commented out in `modules/shared/default.nix:13` — overlays are wired up explicitly in `flake.nix` instead, see the `nixpkgs.overlays` block in `darwinConfigurations.macos`).
- **macOS system defaults (Dock, Finder, keyboard, etc.)** → `hosts/darwin/default.nix` (`system.defaults` / `system.defaults.CustomUserPreferences`).

### Inputs of note

- `onyxvim` (github:aergid/onyxvim?ref=nixcats) provides the Neovim distribution exposed as `pkgs.onyxvim` via an inline overlay in `flake.nix`.
- `claude-code` (github:sadjow/claude-code-nix) provides the `claude-code` package via its own overlay.
- `nix-homebrew` manages Homebrew taps reproducibly on Darwin — taps are pinned as flake inputs (`homebrew-core`, `homebrew-cask`, `homebrew-bundle`) and `mutableTaps = false`.
- `disko` is imported on NixOS but the actual `disk-config.nix` mentioned in `modules/nixos/README.md` is not currently present — partitioning is handled imperatively in `hosts/nixos/default.nix` (`boot.initrd.luks`, `boot.loader.grub`).
- `nodejs` is overridden with `doCheck = false` on Darwin to avoid a flaky test in nixpkgs.

### Conventions

- The username `ksanteen` is hard-coded as `let user = "ksanteen"` in several files (`flake.nix`, `hosts/*/default.nix`, `modules/shared/home-manager.nix`). The `apply` script exists to rewrite these placeholders on a fresh checkout but on this configured tree they are already substituted — edit the literal where needed.
- The Darwin Nix store does not enable `nixpkgs.config` globally for the user — `allowUnfree`/`allowBroken` live in `modules/shared/default.nix` and `NIXPKGS_ALLOW_UNFREE=1` is also exported by the build scripts.
- README files under `modules/{shared,darwin,nixos}/` describe the intended directory layout; some entries (e.g. `cachix`, `disk-config.nix`) are aspirational or partial.
