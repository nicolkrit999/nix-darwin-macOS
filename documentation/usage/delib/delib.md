# `delib` Module Options

With the migration to `denix` and the `delib` framework, all available applications, core services, and system functionalities are declared inside `/modules/` using `delib.module`.

Users can easily enable these capabilities in their host's `default.nix` file within the `myconfig` block.

> **⚠️ OPINIONATED MODULES NOTICE:**
>
> Anything created inside `users/<name>/` or `templates/<name>/` is considered user-specific and opinionated, so you won't find those documented here. These directories are where you should organize your custom standalone functions, specific development flakes, or personal workflows that aren't meant to be shared across every single host.
> *Note:* `templates/` directories are intentionally excluded from `denix` auto-discovery to prevent build crashes when using pure, non-delib Nix files.

---

## 🔝 Top-Level Modules

The `/modules/toplevel/` directory contains core infrastructure variables that can be toggled.

- **`programs.home-manager.enable`** (default: `false`): Enables Home Manager for user-level packages and environment. Practically required for these dots.
- **`programs.zsh.enable`** (default: `false`): Enables the Zsh shell at a system scope. Let the programs.zsh module apply further configurations.
- **`nix.enable`** (default: `true`): Configures Nix core options, experimental features, optimizations, and the garbage collector behavior.
- **`stylix.enable`** (default: `false`): Enables the central theming layer `stylix` to automatically tint system elements, terminals, shells, and supported applications. *(Dependent upon the values placed in `myconfig.constants.theme`)*.

## 🛠️ Programs

The `/modules/programs/` folder provides clean toggles to install individual applications and their associated dotfile configuration logic. By default, if an app is disabled, neither the package nor its config will be placed on the system.

- **`programs.bat.enable`**: Modern syntax-highlighting replacement for `cat`. Supports Catppuccin theme integrations if styling is provided.
- **`programs.claude-code.enable`**: Anthropic's interactive CLI. Injects specific `.zshenv` / `.zshrc` bindings where necessary.
- **`programs.eza.enable`**: Modern replacement for `ls` providing `ll` and `la` aliases on top of icon sets and git integrations.
- **`programs.fish.enable`**: Declarative installation and management of the Fish shell along with common paths and configuration lines.
- **`programs.git.enable`**: Central Git configuration.
  - *Option:* `programs.git.lfs.enable`: Add Git Large File Storage capabilities.
- **`programs.kitty.enable`**: GPU-accelerated terminal emulator setup. Inherits properties seamlessly from Stylix.
- **`programs.lazygit.enable`**: Interactive CLI UI for Git. Often mapped through user configurations as `lg`.
- **`programs.starship.enable`**: Supremely quick, deeply customizable shell prompt supporting Zsh and Fish natively.
- **`programs.tmux.enable`**: Terminal multiplexer bindings + sensible base settings.
- **`programs.zoxide.enable`**: Smart, fast `cd` command alternative that learns your habits.
- **`programs.zsh.enable`** (Shell Config): Applies custom `.zshrc` additions, environments, setup completions, etc.
  - *Option:* `programs.zsh.autosuggestion.enable`: Toggle ghost text completions.
  - *Option:* `programs.zsh.syntaxHighlighting.enable`: Highlight commands prior to execution.

## 🎨 Modifying Program Themes

When Stylix is active, certain programs have optional manual or automated parameters to utilize Catppuccin variants. Depending on your configuration set in your host's `default.nix`, the following modules read specific theming attributes directly:

- `programs.bat` (via `catppuccin.bat.enable`)
- `programs.eza` (via `catppuccin.eza.enable`)
- `programs.kitty` (via `catppuccin.kitty.enable`)
- `programs.lazygit` (via `catppuccin.lazygit.enable`)
- `programs.starship` (via `catppuccin.starship.enable`)
- `programs.tmux` (via `catppuccin.tmux.enable`)
