# 🏠 Home Manager (`home-manager/modules/`)
These configurations define your personal environment. Changes here do not require root access as they only affect the current user.
- When modifying something here it is usually enough to run `hms` to rebuild 

## 📂 Modules (`home-manager/modules/`)

### `alacritty.nix`
Terminal emulator configuration.
* **Theming:** Uses the base16 themes or catppuccin official nix repo based on the user choice in `flake.nix`
* **Font:** Set the font weight (regular/bold, etc) and it chooses the font size in a smart way based on the size of the user monitors
  * In a multi-monitor setup it takes the first one of the monitors list  


### `bat.nix`
Configuration for `bat` (a modern `cat` clone).

* **Theming:** Uses the base16 themes or catppuccin official nix repo based on the user choice in `flake.nix`

### (unused) `cava.nix`
- Currently the nixpkgs version is broken. It is currently installed using brew, but this means that for now it is not configured

An audio visualizer in the terminal. It contains configurable graph stiles bars that follow the audio if the hosts is playing somethihng
* **Theming:** Uses the base16 themes or catppuccin official nix repo based on the user choice in `flake.nix`

### `eza.nix`
Configuration for `eza` (a modern `ls` clone).
* **Theming:** Uses the base16 themes or catppuccin official nix repo based on the user choice in `flake.nix`

### `firefox.nix`
The primary browser configuration.
* **Hardening:** Includes privacy tweaks (disabling telemetry, sponsored tiles).
* **Configuration:** Includes a profile (with the same name as the hosts username) with extensions and bookmarks and homepage
  * The homepage needs to be changed. It's a url that only krit has access to 
* **Theming:** Uses the base16 themes or catppuccin official nix repo based on the user choice in `flake.nix`
  * To alllow theming to work it is necessary to force the `firefox-color` extensions
  * For now there is a `force = true` meaning all extensions are forced to be installed

### `git.nix`
Git version control settings.
* **User-identity:** It takes the github username and e-mail from `flake.nix` (hosts-specific)


### `kitty.nix`
Terminal emulator configuration.
* **Theming:** Uses the base16 themes or catppuccin official nix repo based on the user choice in `flake.nix`
* **Font:** Set the font weight (regular/bold, etc) and it chooses the font size in a smart way based on the size of the user monitors
  * In a multi-monitor setup it takes the first one of the monitors list  


### `lazygit.nix`
Configuration for the terminal UI for Git.
* **Theming:** Uses the base16 themes or catppuccin official nix repo based on the user choice in `flake.nix`


### `maintenance.nix`
System maintenance scripts.
*   **Garbage Collection:** A dedicated module for defining system cleanup rules and generation management.

### `neovim.nix`
Wrapper for the Neovim text editor.
* **Note:** This module only defines a few nix-specific behaviour. The remaining of the config is taken from the regular `~/.config/nvim` folder
* Since neovim is highly customizable it is better to let lua files handle the main configuration
* Stylix is explicitly disabled here to allow for complex, manual Lua-based theming.

### `ranger.nix`
Terminal file manager configuration. Styled via global Stylix Base16 rules.

### `starship.nix`
Shell prompt configuration.
* **Theming:** Uses the base16 themes or catppuccin official nix repo based on the user choice in `flake.nix` 
* **Features** It configures the prompt to show specific symbols for SSH sessions, Git status, and errors.

### `stylix.nix`
The central theming engine for the system.
* **Theming:** Acts as a "switch" between two modes based on the user's choice in `flake.nix`:
    * **Stylix Mode (`catppuccin = false`):** Automatically generates themes for GTK, Wallpapers, and apps using a specific **Base16 scheme** (e.g., `gruvbox`, `dracula`)
  
    * **Catppuccin Mode (`catppuccin = true`):** Disables Stylix's automation for specific apps (like GTK, Alacritty, Hyprland) and manually injects the official **Catppuccin** theme with the user's chosen flavor and accent
      * if `catppuccin` is true then stylix targets should be disabled. This means `*.enable = !catppuccin`
  
* **Features:**
    * **Conditional Logic:** Uses `lib.mkIf` to dynamically enable or disable Stylix targets to prevent conflicts with manual theme modules.
    * 
    * **GTK Overrides:** Manually forces GTK themes and icons when Catppuccin mode is active to ensure deep system integration
    * 
    * **Font Management:** Installs and configures a comprehensive suite of fonts (JetBrains Mono, Noto, FontAwesome) for consistent typography across the OS
    * 
    * **Dark/Light Mode:** Forces the system-wide "prefer-dark" or "prefer-light" signal via `dconf` to ensure GTK4 apps respect the global polarity

### `tmux.nix`
Terminal multiplexer configuration. Includes behaviour and keybindings
* **Theming:** Uses the base16 themes or catppuccin official nix repo based on the user choice in `flake.nix`
* 
* **Features:**
    * **Navigation:** Configures a `keybindings + Arrow keys` to switch panes and a `keybindings + Number keys` to switch windows instantly
    * 
    * **Workflow Shortcuts:** Includes custom bindings to launch specific workspaces like the system configuration or notes directly in Neovim
    * **Window Management:** Sets custom split bindings and resizing shortcuts (`Alt+Shift+Arrows`) for rapid layout control
    * **Vim Mode:** Enables standard Vim keybindings for efficient scrolling and copy-paste operations

### `zsh.nix`
Shell configuration.
* **Function:** Adds Nix-specific aliases (like `hms` for Home Manager Switch) and integrates with an existing `~/.zshrc_custom` file
  * This allow an hybrid setup where one can configure `~/.zshrc_custom` to be valid regardless of os, basically using globally valid aliases and options

