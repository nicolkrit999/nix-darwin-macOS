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

### `cava.nix`
An audio visualizer in the terminal. It contains configurable graph stiles bars that follow the audio if the hosts is playing somethihng
* **Theming:** Uses the base16 themes or catppuccin official nix repo based on the user choice in `flake.nix`

### `eza.nix`
Configuration for `eza` (a modern `ls` replacement).
*   Ensures the tool shares the same color scheme and icons across machines.

### `firefox.nix`
Browser configuration.
*   **Profiles:** Creates a persistent profile for the user.
*   **Extensions:** Manages browser add-ons declaratively.
*   **Styling:** Uses Stylix/Catppuccin to theme the browser UI.

### `git.nix`
Core Version Control configuration.
*   **Identity:** Injects the `gitUserName` and `gitUserEmail` defined in `flake.nix` directly into the Git config.

### `lazygit.nix`
Terminal UI for Git.
*   **Theming:** Configured and themed via Stylix to match the system palette.

### `maintenance.nix`
System maintenance scripts.
*   **Garbage Collection:** A dedicated module for defining system cleanup rules and generation management.

### `neovim.nix`
Text editor configuration.
*   Ensures Neovim shares the system-wide color scheme and keybindings.

### `ranger.nix`
Terminal file manager configuration.
*   Ensures the file manager shares the system-wide color scheme and keybindings.

### `starship.nix`
Shell prompt configuration.
*   **Theming:** Shows different palette colors (Red/Green) based on the success/failure of the previous command.
*   **Logic:** Disabled in Stylix if Catppuccin is active to allow the official Catppuccin preset to load.

### `stylix.nix`
The central theming engine. It unifies system-wide theming into a single file.
*   **Fonts:** Installs and configures JetBrains Mono (Monospace) and Inter (Sans-Serif).
*   **Targets:** Conditionally enables/disables theming for specific apps. For example, if `catppuccin` is enabled, Stylix is told to ignore Starship and Bat so the official Catppuccin modules can take over.

### `tmux.nix`
Terminal multiplexer configuration.
*   Ensures standard configuration and consistent color schemes across sessions.

### `zsh.nix`
Shell configuration.
*   **Aliases:** Defines the `sw` (switch), `upd` (update), and `pkgs` (edit) shortcuts.
*   **Integration:** Sources `~/.zshrc_custom` to allow for non-declarative, local configuration.

