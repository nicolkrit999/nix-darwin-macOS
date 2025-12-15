# ⚙️ Nix-Darwin (`nixDarwin/modules/`)
These modules control the macOS Operating System itself. Changes here affect the Dock, Finder, System Services, and the build daemon.

## `configuration.nix`
The core system configuration.
* **System Defaults:** Configures the macOS Dock (autohide, orientation), Finder (show extensions), and Interface Style (Dark/Light).
* **Security:** Enables `touchIdAuth` for sudo, allowing you to authenticate admin commands with your fingerprint.
* **System Packages:** Installs core CLI tools available to all users (like `git`, `curl`).
* **Homebrew:** Configures the Homebrew integration to manage Casks (GUI apps like Firefox, Alacritty) and Mac App Store apps alongside Nix.

## `nix.nix`
Configures the Nix daemon.
* **Compatibility:** explicitly sets `nix.enable = false` and disables automatic Garbage Collection. This is required when using the **Determinate Systems** installer, as that installer manages the daemon service externally to avoid conflicts with macOS updates. It is instead handled by `maintenance.nix`
* **Settings:** Enables experimental features like `flakes` and `nix-command`.

## `default.nix`
The import hub. It simply imports the other files in this directory to ensure `flake.nix` can load them all at once.