Here is the updated `README.md`. I have corrected the formatting issues (removed the literal asterisks), polished the language for better readability, and added a detailed section dedicated to the NixOS Virtual Machine workflow.

```markdown
# Personal Nix-Darwin Configuration

A declarative macOS system configuration using **Nix-Darwin**, **Home Manager**, and **Nix Flakes**.

### Version Compatibility
- **Nixpkgs & nix-darwin**: Must match versions. Currently using **25.11 (Stable)**.
- **Home Manager**: Should ideally match, currently using **25.11**.

## 📍 Repository Location
**Important:** This repository is designed to be cloned into the main user folder at the following specific path:

```bash
~/nix-darwin-macOS/
```

The system update aliases and VM scripts rely on this specific path to function correctly.

## 🍎 macOS Specific Design

This configuration is strictly for macOS. It manages system settings, package installations, and application preferences specifically for Apple Silicon (`aarch64-darwin`) machines.

## 🚀 Key Features & Architecture

### 1. Hybrid Zsh Configuration

Unlike standard Nix setups that completely override your shell configuration, this setup is designed to work **alongside** a cross-platform dotfiles repository.

*   **No Override:** It uses `initExtra` to append configuration rather than replacing `~/.zshrc` entirely.
*   **Sourcing Strategy:** It sources a general, OS-agnostic `zshrc` located at `~/dotfiles/general-zshrc/.zshrc`.
*   **Mac-Specific Additions:** After sourcing the general file, it adds macOS-specific environment variables and integrations inside `home.nix`.
*   **Aliases:** Mac-specific aliases (like `xcodeaccept` or `cleardns`) are defined in `home.nix`, while general aliases remain in the cross-platform `dotfiles` repo.

**The Init Logic:**
The configuration injects the following logic into Zsh:
1.  **Source General Zshrc:** Loads your shared Linux/Mac config.
2.  **Environment Variables:** Sets `CASE_SENSITIVE` and adds Homebrew binary paths.
3.  **SSH Agent:** Automatically starts the agent and adds the Apple Keychain identity.
4.  **iTerm2 Integration:** Sources shell integration if present.
5.  **VM Functions:** Loads the `vmup` logic.

### 2. Multi-Host Support

You can manage multiple Macs with this single repository.

*   **Supported Machines:** Add your machine names to the `supportedMachines` list in `flake.nix`.
*   **Dynamic Generation:** The configuration automatically generates system definitions for every hostname in that list.

### 3. Home Manager Integration

**Home Manager** is integrated directly into the flake. It handles user-specific configurations (like dotfiles, aliases, and specific tool settings) separate from the system-level settings.

## 🐧 NixOS Virtual Machine (Development Environment)

This configuration includes a built-in **NixOS Virtual Machine**. This allows you to develop, test, and build your NixOS configurations directly on your Mac without needing a separate PC.

### Architecture
The VM runs `aarch64-linux` using QEMU with Apple's Hypervisor Framework (`hvf`) for near-native performance. It is a **headless** VM (CLI/TTY only), making it lightweight and fast.

### Hardware Profiles (Host Specific)
The VM hardware resources are automatically adjusted based on the physical Mac running the command:

| Hostname                   | VM RAM | VM Cores | Disk Limit (Max) |
| :------------------------- | :----- | :------- | :--------------- |
| **MacBook-Air-di-Roberta** | 3 GB   | 2 Cores  | 64 GB            |
| **Krits-MacBook-Pro**      | 12 GB  | 6 Cores  | 128 GB           |

*Note: The disk size is "sparse" (QCOW2). It starts small (~1-2GB) and only grows as you fill it with data, up to the limit listed above.*

### Data Storage
To keep this repository clean, VM data is stored externally:
*   **Location:** `~/nixos-vm-data/`
*   **File:** `nixos.qcow2`

*Tip: To factory reset the VM, simply delete the `nixos.qcow2` file and run `vmup` again.*

### Managing the VM

#### 1. Start the VM
Open your terminal and run:
```bash
vmup
```
*This command automatically detects your host, creates the data directory if needed, and boots the correct VM configuration.*

#### 2. Log In
When the login prompt appears:
*   **User:** `nixos`
*   **Password:** `nixos`

#### 3. Post-Login (First Run)
Once inside the VM, your environment is ready. You should now clone your actual NixOS configuration repository to begin development:

```bash
# Example
git clone https://github.com/YOUR_USERNAME/YOUR_NIXOS_REPO.git
cd YOUR_NIXOS_REPO
# ... proceed with your standard NixOS workflow
```

#### 4. Stop the VM
From inside the VM:
```bash
sudo poweroff
```
Or from your Mac terminal (if the window hangs):
```bash
vmstop
```

## 🛠 System Configuration (`flake.nix`)

### Environment & Java
*   **Nix Settings:** Flakes and `nix-command` are enabled. `allowUnfree` is true.
*   **Java:** `JAVA_HOME` is explicitly set to `jdk25`.
*   **JDTLS:** `JDTLS_BIN` is exported globally. The binary is linked to `~/tools/jdtls`.

### Python Environment
Python packages are bundled into a single environment rather than installed globally. This wrapper includes `pip`, `black`, `ruff`, `pynvim`, and language servers to ensure a cohesive development environment.

### Security
**Touch ID for Sudo** is enabled via `security.pam.services.sudo_local`. You can authenticate `sudo` commands using your fingerprint.

### Homebrew Management
Managed declaratively through Nix.
*   **Cleanup:** `uninstall` (Removes packages not listed in the flake).
*   **Behavior:** Auto-update is disabled during builds for speed.
*   **Separation:**
    *   *Taps:* Repositories.
    *   *Brews:* CLI tools.
    *   *Casks:* GUI Apps & Fonts.

## 🧩 Home Manager & Nix Index (`home.nix`)

### Nix-Index Database
The configuration imports `nix-index-database` to provide a comprehensive package list for tools like `comma` or `pay-respects`.
*   **Prompt Disabled:** `enableZshIntegration` is `false` to prevent Nix from hijacking "command not found" errors.

### JDTLS Linking
A symlink is created at `~/tools/jdtls` pointing to the Nix store path. This allows the shared/general `.zshrc` to rely on a stable path for the Java Language Server across different operating systems.

## 🔄 The Update Mechanism (`nixpush`)

To update your system, use the alias `nixpush`.

```bash
nixpush
```

**How it works:**
1.  Navigates to `~/nix-darwin-macOS/`.
2.  Dynamically fetches the Mac's `LocalHostName`.
3.  Matches the name against the `supportedMachines` list.
4.  Builds and switches to the new configuration using `sudo`.
```

