#  Personal Nix-Darwin Config

- [ Personal Nix-Darwin Config](#-personal-nix-darwin-config)
  - [✨ Features](#-features)
    - [🖥️ Adaptive Host Support](#️-adaptive-host-support)
    - [🎨 Unified Theming (Stylix)](#-unified-theming-stylix)
    - [🏠 Home Manager Integration](#-home-manager-integration)
    - [🍎 macOS System Defaults](#-macos-system-defaults)
    - [⚡ Zsh + Starship](#-zsh--starship)
  - [🚀 Installation](#-installation)
    - [1. Install Nix](#1-install-nix)
  - [2. Clone the Repository](#2-clone-the-repository)
  - [3. Create Your Host Configuration](#3-create-your-host-configuration)
  - [4. Configure the host-specific aspects](#4-configure-the-host-specific-aspects)
    - [local-packages.nix](#local-packagesnix)
    - [variables.nix](#variablesnix)
  - [5. First Time Build](#5-first-time-build)
  - [🔄 Daily Usage](#-daily-usage)
  - [❓ Troubleshooting](#-troubleshooting)
  - [Other resources](#other-resources)
    - [Structure](#structure)
    - [Issues](#issues)
    - [Ideas](#ideas)

---

## ✨ Features

### 🖥️ Adaptive Host Support
Define unique parameters (monitor resolutions for wallpaper scaling, usernames, git credentials) per MacBook while keeping the core environment identical.

### 🎨 Unified Theming (Stylix)
A central theme engine that controls the look of the entire system.
* **Modes:** Switch between a generated **Base16** theme or the official **Catppuccin** implementation.
* **Scope:** Controls Terminal colors (Alacritty), Shell prompts (Starship), and application themes (Bat, Lazygit, Firefox).

### 🏠 Home Manager Integration
Fully declarative management of user dotfiles and applications. It defines terminal, shell, browser, and git settings, whihc are reproducible across any Mac.

### 🍎 macOS System Defaults
Declarative configuration of macOS behavior:
* **Dock:** Auto-hide, icon size, and orientation.
* **Finder:** Show all file extensions, default view modes.
* **TouchID:** Enabled for `sudo` commands (no more typing passwords for admin tasks).

### ⚡ Zsh + Starship
A hybrid shell setup. It provides a robust default environment managed by Nix but respects a local `.zshrc_custom` for machine-specific aliases or work-related configs that shouldn't be committed to Git.

---

## 🚀 Installation

### 1. Install Nix
This configuration is built for the **Determinate Systems** Nix installer (which allows `nix.enable = false` in the config).

Run the installer:
```bash
curl --proto '=https' --tlsv1.2 -sSf -L [https://install.determinate.systems/nix](https://install.determinate.systems/nix) | sh -s -- install
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

**(Optional) Edit Local Packages:**
Open `hosts/<Your-Hostname>/local-packages.nix` to add or remove software specific to this machine (e.g., if you don't need gaming tools on a work laptop).



## 4. Configure the host-specific aspects

### local-packages.nix
This file contains packages that are installed only for that specific hosts.
- Change accordingly


### variables.nix
This file contains aspects that can change between hosts, such as theming
- Make sure to define every variable otherwise the build would fail


**Variables to customize:**
*   **hostname**: Needs to match the one found
*   **user:**: needs to match the mac user.
*   **monitorConfig:**: Used for font scaling logic in Alacritty.
*   **base16Theme**: The general theming, it will be applied to all modules enabled in `stylix.nix`
*   **polarity**: Whatever the general theme should be light/dark. It should make sense with the chosen base16Theme
*   **catppuccin**: Whatever to enable catppuccin or not
*   **catppuccinFlavor**: Which flavor to choose
    * latte/frappe/macchiato/mocha
*  **catppuccinAccent**:** Refer to [palette](https://catppuccin.com/palette/)
*  **gitUserName**: Username of github account
*  **gitUserEmail**: E-Mail of github account   

An example:
```nix
{
  # 💻 HOST IDENTITY
  hostname = "Krits-MacBook-Pro";
  user = "krit";
  system = "aarch64-darwin";

  # ⚙️ SYSTEM SETTINGS
  monitorConfig = [ "eDP-1,3024x1964,1" ];

  # 🎨 THEMING
  base16Theme = "nord";
  polarity = "dark";

  # Catppuccin Logic (Disable if using Nord)
  catppuccin = false;
  catppuccinFlavor = "macchiato"; # Unused if false
  catppuccinAccent = "mauve";

  # 🐙 GIT CONFIG
  gitUserName = "nicolkrit999";
  gitUserEmail = "githubgitlabmain.hu5b7@passfwd.com";
}

```



## 5. First Time Build

Build the flake to switch your system to the Nix configuration. Replace `<hostname>` with the name defined in your flake.

```bash
nix run nix-darwin -- switch --flake .#<hostname>
```

---

## 🔄 Daily Usage

Once installed, use the convenient aliases configured in `zsh.nix` to manage your system.

| Command | Description                                                               |
| :------ | :------------------------------------------------------------------------ |
| `sw`    | **Switch**. Rebuilds the System and Home Manager configuration.           |
| `upd`   | **Update**. Updates `flake.lock` (packages) and then rebuilds the system. |
| `pkgs`  | **Edit**. Opens the Home Manager modules folder in Neovim.                |
| `fmt`   | **Format**. Formats all `.nix` files in the repo using `nixfmt`.          |

---

## ❓ Troubleshooting

**Error: experimental-features 'flakes' is disabled**
*   **Fix:** The installer should handle this, but if not, ensure `~/.config/nix/nix.conf` contains:
    `experimental-features = nix-command flakes`

**Error: home-manager options not found**
*   **Cause:** You might be mixing up system-level options with Home Manager options.
*   **Fix:** Ensure app-specific settings (like `programs.zsh`) are inside `home-manager/modules`, not `nixDarwin/modules`.
*   



## Other resources
### [Structure](./Documentation/structure/Structure.md)
These files contains the entire structure of the project, with an explanation of every single file

### [Issues](./Documentation/issues/issues.md)
These file contains issues that i noticed that should be resolved
- Issues include both warnings than critical one

### [Ideas](./Documentation/ideas/ideas.md)
These file contains ideas that i think may benefit the project


