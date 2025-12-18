# 📂 Project Structure

This repository separates the **System Configuration** (macOS settings/Daemons) from the **User Configuration** (Apps/Dotfiles).

Categories can be navigated with the links below:

* **[❄️ Core Configuration](./sections/Core.md)**: Entry point (`flake.nix`), inputs, and host definitions.
* **[⚙️ System Modules (NixDarwin)](./sections/NixDarwin.md)**: macOS defaults, Nix daemon, and system packages.
* **[🏠 User Modules (Home Manager)](./sections/HomeManager.md)**: Applications, themes, shells, and browsers.

## 🌳 File Tree

```text
.
├── flake.nix                         # ❄️ Entry point: Inputs, hosts, and global variables
├── flake.lock                        # 🔒 Dependency lockfile
│
├── home-manager/                    # 🏠 User-specific configuration
│   └── modules/
│       ├── alacritty.nix            # Terminal settings & font scaling
│       ├── bat.nix                  # 'cat' clone theming
│       ├── default.nix              # Module importer
│       ├── eza.nix                  # 'ls' clone settings
│       ├── firefox.nix               # Browser profiles & hardening
│       ├── git.nix                  # Git credentials
│       ├── lazygit.nix              # Git TUI settings
│       ├── maintenance.nix          # Custom maintenance scripts/aliases
│       ├── neovim.nix               # Editor wrapper (uses external config)
│       ├── ranger.nix               # File manager
│       ├── starship.nix             # Shell prompt
│       ├── stylix.nix               # 🎨 Central Theming Engine (Unified)
│       ├── tmux.nix                 # Terminal Multiplexer
│       └── zsh.nix                  # Shell aliases & history
│
├── hosts/                           # 🖥️ Host-specific data
│   ├── Krits-MacBook-Pro/
│   │   └── local-packages.nix       # Packages specific to this Pro
│   └── MacBook-Air-di-Roberta/
│       └── local-packages.nix       # Packages specific to this Air
│
└── nixDarwin/                       # ⚙️ System-wide Modules (Root)
    └── modules/
        ├── configuration.nix         # macOS System Defaults (Dock, Finder)
        ├── default.nix              # Import hub
        └── nix.nix                  # Nix Daemon & GC settings

