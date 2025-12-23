# ❄️ Core Configuration

This section covers the entry point of the configuration and host definitions.

## 🧠 Flake Entry Point (`flake.nix`)
The brain of the operation. It defines the inputs (Nixpkgs source, Home Manager, Stylix, Catppuccin) and creates the `darwinConfigurations`.

* **`mkSystem` Function:** A wrapper function that generates a system configuration. It accepts arguments like `monitorConfig`, and `user`, passing them down to all modules via `specialArgs` and `extraSpecialArgs`.
* **Fallbacks:** The flake contains logic to provide default values (e.g., for catppuccin) if a host does not explicitly define them.
* **Formatter:** Defines `nixfmt-rfc-style` as the default formatter for `nix fmt`.

## 🖥️ Hosts (`hosts/`)
This directory contains the configurations for specific machines. Each folder name need to match the name of a `hostname` defined in `flake.nix`.

### A note about hardware-configuration.nix
In this setup it is not needed because telling that the architecture is `aarch64-darwin` is enough

Each hosts folder should contain these 3 files:

* ### `host-settings.nix` ###
This file is a centralized place for settings that are unique to a specific machine (e.g., `Krits-MacBook-Pro`).

* **Mac App Store Apps (`masApps`):** Lists applications to be installed from the Mac App Store. These are defined by their App Store ID.
* *Note:* You must be signed into the App Store for these to install.


* **System Defaults:** Customizes macOS behavior specifically for this machine.
* **Dock:** Settings like position, size, auto-hide, and persistent app icons.
* **Finder:** Settings like showing file extensions, default search scope, and desktop icons.
* **Global Settings:** Keyboard repeat rate, scroll bars, and window behavior.
* **Custom Preferences:** Advanced tweaks for specific apps or system behaviors that aren't exposed as top-level Nix options.


* ### `local-packages.nix` ###
* Some packages may not be needed in all the machines. For example why installing developing tools when not programming
  * When the package contains -> ⚠️ KEEP it means that for me they are necessary. Another person if it does not need that specific package it is free to remove it


* ### `variables.nix` ###
* It defines the specific variables for that certain host
