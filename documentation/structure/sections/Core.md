# ❄️ Core Configuration

This section covers the entry point of the configuration and host definitions.

## 🧠 Flake Entry Point (`flake.nix`)
The brain of the operation. It defines the inputs (Nixpkgs source, Home Manager, Stylix, Catppuccin) and creates the `darwinConfigurations`.

* **`mkSystem` Function:** A wrapper function that generates a system configuration. It accepts arguments like `monitorConfig`, and `user`, passing them down to all modules via `specialArgs` and `extraSpecialArgs`.
* **Fallbacks:** The flake contains logic to provide default values (e.g., for catppuccin) if a host does not explicitly define them.
* **Formatter:** Defines `nixfmt-rfc-style` as the default formatter for `nix fmt`.

## 🖥️ Hosts (`hosts/`)
This directory contains the configurations for specific machines. Each folder name need to match the name of a `hostname` defined in `flake.nix`.

Each hosts folder should contain these 3 files


* ### `configuration.nix` ###
* The machine-specific entry point. It imports the hardware scan and any host-specific module overrides.

* ### `hardware'configuration.nix` ###
* An auto-generated file which contains optimization based on the hardware of that specific machine.
* This file should not be changed unless the user is confident

* ### `local-packages.nix` ###
* Some packages may not be needed in all the machines. For example why installing developing tools when not programming
  * When the package contains -> ⚠️ KEEP it means that for me they are necessary. Another person if it does not need that specific package it is free to remove it