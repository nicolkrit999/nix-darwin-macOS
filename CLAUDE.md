# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A flake-based, multi-host **nix-darwin** configuration for macOS (aarch64-darwin). It uses nix-darwin for system-level config, home-manager for user-level config, Stylix for unified theming, and sops-nix for encrypted secrets.

## Apply Changes

```bash
darwin-rebuild switch --flake .#<hostname>
# or use the alias (defined in zsh/fish config):
sw
```

Other common operations:
```bash
nix flake update && sw   # update inputs then rebuild (alias: upd)
nix fmt                  # format all .nix files with nixfmt-rfc-style (alias: fmt)
```

## Repository Architecture

### How Hosts Are Built

`flake.nix` dynamically discovers hosts by scanning `hosts/` for directories containing `configuration.nix`. For each host it calls `makeSystem`, which:
1. Loads `hosts/<hostname>/variables.nix` as `vars` (passed as `specialArgs` to all modules)
2. Imports `hosts/<hostname>/configuration.nix` (nix-darwin system config)
3. Imports `nixDarwin/modules/` (shared system defaults)
4. Mounts home-manager, passing `hosts/<hostname>/home.nix` as the user config

### Three Layers of Config

| Layer | Location | Purpose |
|-------|----------|---------|
| Shared system | `nixDarwin/modules/` | Dock, Finder, Touch ID sudo, Nix settings, system packages — auto-applied to all hosts |
| Shared home-manager | `home-manager/` | Shell configs (fish, zsh), git, kitty, tmux, starship, bat, eza, lazygit, stylix — auto-applied to all hosts |
| Host-specific | `hosts/<hostname>/` | Identity, SOPS secrets, Homebrew apps, SSH/git configs, opt-in modules |

### `variables.nix` Is the Source of Truth

Every host has `hosts/<hostname>/variables.nix` defining identity and preferences. This is passed as `vars` to all modules. Never hardcode values that belong here:

```nix
{
  hostname = "Krits-MacBook-Pro";
  user = "krit";
  system = "aarch64-darwin";
  shell = "fish";           # fish | zsh | bash
  term = "kitty";
  editor = "nvim";
  browser = "firefox";
  base16Theme = "nord";     # Stylix theme
  polarity = "dark";        # light | dark
  # catppuccin.enable = false; catppuccinFlavor = "mocha"; catppuccinAccent = "blue";
  gitUserName = "...";
  gitUserEmail = "...";
}
```

### Opt-In Modules (`common/krit/`)

Reusable modules that hosts explicitly import — not auto-applied. Organized as:
- `cli-programs/`: neovim, direnv, cava
- `gui-programs/`: firefox, librewolf, chromium (with privacy profiles)
- `terminal-emulators/`: kitty, alacritty
- `file-managers/`: yazi (with Lua config), ranger
- `nas/`: SMB/SSH/OwnCloud NAS access
- `dev-environments/`: Standalone flakes per language (Go, Rust, Python, Node, Haskell, C/C++, Java, Swift, R, LaTeX, Typst, Jupyter, PHP, Shell, web-dev combos) — use with direnv

Host opt-in modules live in `hosts/<hostname>/optional/` and are imported from `configuration.nix` or `home.nix`.

### Theming

Stylix with base16 themes flows: `variables.nix` (base16Theme + polarity) → `home-manager/modules/stylix.nix` → program-specific theme application. Catppuccin is opt-in per-host.

### Secrets (sops-nix)

Encrypted YAML files at `hosts/<hostname>/optional/host-sops-nix/` (host-specific) and `common/krit/sops/` (shared). Age keys defined in `.sops.yaml` — both the user key and host key can decrypt.

### Package Channels

- `pkgs` — nixpkgs stable (nixpkgs-25.11-darwin)
- `pkgs.unstable` — nixpkgs-unstable overlay, available via `pkgs-unstable` specialArg

## Adding a New Host

1. Create `hosts/<hostname>/` with `variables.nix`, `configuration.nix`, `home.nix`
2. The flake auto-discovers it — no changes to `flake.nix` needed
3. Create `optional/` if host-specific opt-in modules are needed

## Nix Code Conventions

- Formatter: `nixfmt-rfc-style` (2-space indentation)
- Module signature: `{ config, pkgs, lib, ... }:`
- Prefer explicit `lib.` prefixes over `with lib;`
- Use `mkIf`, `mkMerge`, `mkOption`, `mkDefault` for module composition
- Host-specific logic stays in `hosts/<hostname>/`; shared modules must not reference host-specific values directly
