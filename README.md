#  Personal Nix-Darwin Config

- [ Personal Nix-Darwin Config](#-personal-nix-darwin-config)
  - [✨ Features](#-features)
    - [🖥️ Adaptive Host Support (Denix)](#️-adaptive-host-support)
    - [🎨 Unified Theming (Stylix)](#-unified-theming-stylix)
    - [🏠 Home Manager Integration](#-home-manager-integration)
    - [🍎 macOS System Defaults](#-macos-system-defaults)
    - [⚡ Shell Environment](#-shell-environment)
  - [🚀 Installation](#-installation)
    - [1. Install Nix](#1-install-nix)
  - [2. Clone the Repository](#2-clone-the-repository)
  - [3. Create Your Host Configuration](#3-create-your-host-configuration)
  - [4. Configure the host-specific aspects](#4-configure-the-host-specific-aspects)
    - [default.nix (Source of Truth)](#defaultnix-source-of-truth)
    - [system.nix & home.nix](#systemnix--homenix)
    - [Opinionated directories and exclusions](#opinionated-directories-and-exclusions)
  - [5. First Time Build](#5-first-time-build)
  - [🔄 Daily Usage](#-daily-usage)
  - [❓ Troubleshooting](#-troubleshooting)

---

## ✨ Features

### 🖥️ Adaptive Host Support
Built on the **denix** library, this configuration uses auto-discovery for all modules. Define unique parameters (monitor resolutions for wallpaper scaling, usernames, git credentials) per MacBook while keeping the core environment identical. No manual imports needed!

### 🎨 Unified Theming (Stylix)
A central theme engine that controls the look of the entire system.
* **Modes:** Switch between a generated **Base16** theme or the official **Catppuccin** implementation.
* **Scope:** Controls Terminal colors (Alacritty/Kitty), Shell prompts (Starship), and application themes (Bat, Lazygit, Firefox).

### 🏠 Home Manager Integration
Fully declarative management of user dotfiles and applications. It defines terminal, shell, browser, and git settings, which are reproducible across any Mac.

### 🍎 macOS System Defaults
Declarative configuration of macOS behavior:
* **Dock:** Auto-hide, icon size, and orientation.
* **Finder:** Show all file extensions, default view modes.
* **TouchID:** Enabled for `sudo` commands (no more typing passwords for admin tasks).

### ⚡ Shell Environment
Uses fish as the primary shell with a robust default environment managed by Nix.

---

## 🚀 Installation

### 1. Install Nix
This configuration is built for the **Determinate Systems** Nix installer (which allows `nix.enable = false` in the config).

Run the installer:
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```


---

## 2. Clone the Repository

Clone this repository to your home directory (usually `~/nix-darwin-macOS` or similar).

```bash
git clone https://github.com/nicolkrit999/nix-darwin-macOS.git
cd nix-darwin-macOS
```

---

## 3. Create Your Host Configuration

If your machine is not `Krits-MacBook-Pro`, you need to create a host folder for it.

**Find your Hostname:**
Run this command to see what macOS calls your computer:

```bash
scutil --get LocalHostName
```

**Duplicate the Template:**
Copy the existing template folder to a new folder named exactly like your Hostname.

```bash
cd hosts
cp -r Krits-MacBook-Pro <Your-Hostname>
```

---

## 4. Configure the host-specific aspects

With the migration to `denix` and the `delib` module system, host configuration is centralized.

### default.nix (Source of Truth)
This file uses `delib.host` and contains the constants and module enablement for the host.
Variables like theming, hostname, and user are defined here under `myconfig.constants`. Shared and user modules are enabled here (e.g., `programs.bat.enable = true;`).

**Variables to customize in `constants`:**
*   **hostname**: Needs to match the folder name
*   **user:**: Needs to match the Mac user.
*   **terminal**, **shell**, **browser**, **editor**: Default applications
*   **theme.base16Theme**: The general theming (applied via stylix)
*   **theme.polarity**: Light or dark mode
*   **theme.catppuccin**: Whether to enable catppuccin or not
*   **gitUserName**: Username of github account
*   **gitUserEmail**: E-Mail of github account

An example snippet from `default.nix`:
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
      theme = {
        polarity = "dark";
        base16Theme = "nord";
        catppuccin = false;
      };
      # ...
    };

    # Enable shared modules
    programs.git.enable = true;
    # ...
  };
}
```

### system.nix & home.nix
Contains `darwin` (system-level) and `home-manager` (user-level) configurations specific to this host, wrapped in `delib.host` blocks.

### Opinionated directories and exclusions
By design, anything within `users/<name>` or `templates/<name>` is considered opinionated.
- **`users/<name>`**: For module logic specific to a given user/workflow. Users can just add a new folder matching their name and import those modules into their `default.nix` in the host file.
- **`templates/<name>`**: For standard Nix functions that intentionally lack a `delib` wrapper since they are excluded from the auto-discovery engine. It protects standard structural Nix concepts (like dev environment flakes) from breaking the build process because auto-discovery expects `delib.module`. Any user module requiring non-delib logic should be organized here.

See [delib documentation](./documentation/usage/delib/delib.md) for details on available shared modules.

## 5. First Time Build

Build the flake to switch your system to the Nix configuration. Replace `<hostname>` with the name defined in your flake.

```bash
nix run nix-darwin -- switch --flake .#<hostname>
```

---

## 🔄 Daily Usage

Once installed, use the convenient aliases configured to manage your system.

| Command | Description                                                               |
| :------ | :------------------------------------------------------------------------ |
| `sw`    | **Switch**. Rebuilds the System and Home Manager configuration.           |
| `upd`   | **Update**. Updates `flake.lock` (packages) and then rebuilds the system. |
| `fmt`   | **Format**. Formats all `.nix` files in the repo using `nixfmt`.          |

---

## ❓ Troubleshooting

**Error: experimental-features 'flakes' is disabled**
*   **Fix:** The installer should handle this, but if not, ensure `~/.config/nix/nix.conf` contains:
    `experimental-features = nix-command flakes`
