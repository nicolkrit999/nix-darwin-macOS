# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A flake-based, multi-host **nix-darwin** configuration for macOS (aarch64-darwin) built on the **denix** library (yunfachi/denix). It uses nix-darwin for system-level config, home-manager for user-level config, Stylix for unified theming, and sops-nix for encrypted secrets. All modules use `delib.module` / `delib.host` wrappers with automatic path discovery.

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

### How Hosts Are Built (denix auto-discovery)

`flake.nix` calls `denix.lib.configurations` which **automatically discovers** all `.nix` files under the configured paths. For each host it finds a `delib.host` block with a matching `name`. No manual imports needed.

```nix
paths = [ ./hosts ./modules ./packages ./users ];
exclude = [ ./users/krit/dev-environments ];
```

Key flake settings:
- `moduleSystem` — `"darwin"` for `darwinConfigurations`, `"home"` for `homeConfigurations`
- `homeManagerUser = "krit"` — hardcoded home-manager user
- `specialArgs` passes `inputs`, `moduleSystem`, and `pkgs-unstable`

### Module System (delib)

Every `.nix` file (except those in `exclude`) is auto-discovered. There are two types:

| Type | Wrapper | Purpose |
|------|---------|---------|
| `delib.module` | Shared reusable module | Declares options + config in `darwin.always`, `darwin.ifEnabled`, `home.always`, `home.ifEnabled` blocks |
| `delib.host` | Host-specific config | Sets `name`, `type`, `homeManagerSystem`, and provides `myconfig`, `darwin`, `home` blocks |

Module enable/disable is controlled in the host's `default.nix` via `myconfig` options (e.g., `programs.bat.enable = true`).

### Three Layers of Config

| Layer | Location | Purpose |
|-------|----------|---------|
| Shared modules | `modules/` | Programs (bat, eza, fish, git, kitty, etc.), toplevel config (stylix, nix, common-configuration, user, home, home-packages) — auto-discovered, enabled per-host |
| User modules | `users/<username>/modules/` | User-specific opt-in modules (neovim, direnv, firefox, librewolf, yazi, NAS services, etc.) — auto-discovered, enabled per-host via `myconfig.<username>.*` options |
| Host-specific | `hosts/<hostname>/` | Identity (`default.nix`), system config (`system.nix`), home config (`home.nix`), local packages, SOPS secrets |

### `default.nix` Is the Source of Truth

Every host has `hosts/<hostname>/default.nix` using `delib.host` that defines constants and enables modules. Constants are set via `myconfig.constants`:

```nix
{ delib, ... }:
delib.host {
  name = "Krits-MacBook-Pro";
  type = "desktop";
  homeManagerSystem = "aarch64-darwin";

  myconfig = { ... }: {
    constants = {
      hostname = "Krits-MacBook-Pro";
      user = "krit";
      uid = 501;
      terminal = "kitty";
      shell = "fish";
      browser = "firefox";
      editor = "nvim";
      fileManager = "yazi";
      theme = {
        polarity = "dark";
        base16Theme = "nord";
        catppuccin = false;
        catppuccinFlavor = "macchiato";
        catppuccinAccent = "mauve";
      };
      gitUserName = "...";
      gitUserEmail = "...";
    };

    # Enable shared modules
    programs.bat.enable = true;
    programs.fish.enable = true;
    # ...

    # Enable user modules
    krit.programs.neovim.enable = true;
    krit.services.nas.sshfs.enable = true;
    # ...
  };
}
```

### Constants System (`modules/config/constants.nix`)

Declares all shared option types via `delib.moduleOptions`. Constants set in a host's `default.nix` are accessible in all modules as `myconfig.constants.*`. Also exported as `args.shared.constants` for cross-module access.

### User Modules (`users/<username>/`)

Reusable modules under `<username>.*` namespace that hosts explicitly enable. For example, under `users/krit/`:
- `modules/programs/cli-programs/`: neovim, direnv, cava
- `modules/programs/gui-programs/`: firefox, librewolf, chromium
- `modules/programs/terminal-emulators/`: kitty, alacritty
- `modules/programs/file-managers/`: yazi (with Lua config), ranger
- `modules/services/nas/`: SMB, SSH, OwnCloud, borg-backup
- `sops/`: Shared encrypted secrets (krit-common-secrets-sops.yaml)

### Templates (`templates/<username>/`)

**Important Exclusions**: Plain Nix functions (not delib modules) imported by other modules. `denix` expects everything auto-discovered to be wrapped in a `delib` function. This directory is strictly for pure Nix logic (like Dev Environment standalone flakes or complex record exports) that prevents build failures from auto-discovery interpreting them as module definitions.

### Theming

Stylix with base16 themes flows: host `default.nix` (constants.theme) → `modules/toplevel/stylix.nix` → program-specific theme targets. Catppuccin is opt-in per-host. The stylix module handles both darwin and home-manager layers, with conditional `homeModules.stylix` import for standalone home configurations.

### Secrets (sops-nix)

Encrypted YAML files:
- Host-specific: `hosts/<hostname>/<Hostname>-secrets-sops.yaml`
- Shared: `users/<username>/sops/<Shared>-secrets-sops.yaml`

Age keys for decryption. SOPS config is in the host's `system.nix`.

### Package Channels

- `pkgs` — nixpkgs stable (nixpkgs-25.11-darwin)
- `pkgs-unstable` — nixpkgs-unstable, passed as `specialArgs`

### Placeholder Directories

- `packages/` — for custom package definitions (currently empty, `.gitkeep`)
- `modules/services/` — for shared service modules (currently empty, `.gitkeep`)

## Adding a New Host

1. Create `hosts/<hostname>/default.nix` with `delib.host` — set `name`, constants, and enable desired modules
2. Create `system.nix` (darwin config) and `home.nix` (home-manager config) as additional `delib.host` blocks
3. The flake auto-discovers it — no changes to `flake.nix` needed
4. Add host-specific packages via a `delib.module` with a namespaced enable option

## Nix Code Conventions

- Formatter: `nixfmt-rfc-style` (2-space indentation)
- Module wrapper: `delib.module` for shared modules, `delib.host` for host-specific config
- Module signature: `{ delib, pkgs, lib, ... }:` (outer scope); `{ myconfig, cfg, ... }` (inner delib lambdas)
- Prefer explicit `lib.` prefixes over `with lib;`
- Use `mkIf`, `mkMerge`, `mkOption`, `mkDefault`, `mkForce` for module composition
- Host-specific logic stays in `hosts/<hostname>/`; shared modules access host values via `myconfig.constants`
- Standard args (pkgs, lib, config, inputs) go in the outer function scope, NOT in `.ifEnabled` lambdas

## Developer Configuration

Personal preferences (editor config, personal shortcuts, code style opinions) belong in your
**user-level** Claude Code config, not in this project file:

- Linux/macOS: `~/.claude/CLAUDE.md` and `~/.claude/rules/`
- Windows: `%USERPROFILE%\.claude\CLAUDE.md` and `%USERPROFILE%\.claude\rules\`

Auto memory is machine-local by default. Do **not** set `autoMemoryDirectory` in
`.claude/settings.local.json` — keeping it unset means each developer's memory stays on their
own machine and doesn't cause noise across environments.
