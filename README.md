````markdown
# Personal Nix-Darwin Configuration

A declarative macOS system configuration using **Nix-Darwin**, **Home Manager**, and **Nix Flakes**.

## 📍 Repository Location
**Important:** This repository is designed to be cloned into the main user folder at the following specific path:


~/nix-darwin-macOS/
````

The system update aliases rely on this specific path to function correctly.

## 🍎 macOS Specific Design

This configuration is strictly for macOS. It manages system settings, package installations, and application preferences specifically for Apple Silicon (`aarch64-darwin`) machines.

## 🚀 Key Features & Architecture

### 1\. Hybrid Zsh Configuration

Unlike standard Nix setups that completely override your shell configuration, this setup is designed to work **alongside** a cross-platform dotfiles repository.

  * **No Override:** It uses `initContent` to append configuration rather than replacing `~/.zshrc` entirely.
  * **Sourcing Strategy:** It sources a general, OS-agnostic `zshrc` located at `~/dotfiles/general-zshrc/.zshrc`.
  * **Mac-Specific Additions:** After sourcing the general file, it adds macOS-specific environment variables and integrations inside `home.nix`.
  * **Aliases:** Mac-specific aliases (like `xcodeaccept` or `cleardns`) are defined in `home.nix`, while general aliases remain in the cross-platform `dotfiles` repo.

**The `initContent` Logic:**
The configuration injects the following logic into Zsh:

1.  **Source General Zshrc:** Loads your shared Linux/Mac config.
2.  **Environment Variables:** Sets `CASE_SENSITIVE` and adds Homebrew binary paths.
3.  **SSH Agent:** Automatically starts the agent and adds the Apple Keychain identity.
4.  **iTerm2 Integration:** Sources shell integration if present.

### 2\. Multi-Host Support

You can manage multiple Macs with this single repository.

  * **Supported Machines:** Add your machine names to the `supportedMachines` list in `flake.nix`.
  * **Dynamic Generation:** The configuration automatically generates system definitions for every hostname in that list.

### 3\. Home Manager Integration

**Home Manager** is enabled and integrated directly into the flake. It handles user-specific configurations (like dotfiles, aliases, and specific tool settings) separate from the system-level settings.

## 🛠 System Configuration (`flake.nix`)

### Environment & Java

  * **Nix Settings:** Flakes and `nix-command` are enabled by default. `allowUnfree` is true.
  * **Java:** `JAVA_HOME` is explicitly set to the installed `jdk25` package.
  * **JDTLS:** `JDTLS_BIN` is exported globally, pointing to the nix-installed language server. The folder that contains it is in ~/tools/jdtls

### Python Environment

Instead of listing Python packages individually in the global list, a wrapper block is used:

```nix
(pkgs.python313.withPackages (ps: with ps; [ ... ]))
```

This bundles the interpreter with essential tools (pip, black, ruff, pynvim, etc.) into a single callable environment, preventing the need to reinstall packages manually via pip.

### Security

**Touch ID for Sudo** is enabled via `security.pam.services.sudo_local`. You can authenticate `sudo` commands using your fingerprint instead of typing your password.

### Homebrew Management

Homebrew is managed declaratively through Nix.

  * **Cleanup:** set to `"uninstall"`. If a package is removed from `flake.nix`, it will be automatically uninstalled from your system.
  * **Optimization:** `autoUpdate` and `upgrade` are disabled during rebuilds to speed up the process.
  * **Configuration:**
      * **Taps:** Third-party package repositories.
      * **Brews:** CLI-only tools (e.g., `pipes-sh`).
      * **Casks:** GUI applications and Fonts (e.g., `only-switch`, `font-jetbrains-mono-nerd-font`).

## 🧩 Home Manager & Nix Index (`home.nix`)

### Nix-Index Database & Command Not Found

The configuration imports the `nix-index-database` module.

  * **Database:** This ensures tools like `pay-respects` have access to a list of all available packages.
  * **Prompt Disabled:** `enableZshIntegration` is set to **false**. This prevents Nix from hijacking the "command not found" error with its own interactive prompt, allowing your preferred typo-correction tools to run instead.

### JDTLS Linking

A symlink for the Java Language Server is created at:
`~/tools/jdtls` -\> points to Nix store path.

This allows the **general `zshrc`** (which is shared with Linux machines) to rely on a fixed path (`~/tools/jdtls`) for the language server, regardless of where Nix installs it on the specific OS.

## 🔄 The Update Mechanism (`nixpush`)

To update your system, use the alias `nixpush`.

```bash
nixpush
```

**How it works:**
The command is defined as:
`cd ~/nix-darwin-macOS/ && sudo nix run nix-darwin -- switch --flake ".#$(scutil --get LocalHostName)"`

1.  It navigates to the repo folder.
2.  It runs `scutil --get LocalHostName` to dynamically fetch your Mac's current hostname.
3.  It matches that name against the `supportedMachines` list in the flake.
4.  It builds and switches to the correct configuration automatically.

<!-- end list -->

```
```
