# ❄️ Core Configuration

This section covers the entry point of the configuration and host definitions.

## 🧠 Flake Entry Point (`flake.nix`)
The brain of the operation. It defines the inputs (Nixpkgs source, Home Manager, Stylix, Catppuccin) and creates the `darwinConfigurations`.

* **`mkSystem` Function:** A wrapper function that generates a system configuration. It accepts arguments like `monitorConfig`, and `user`, passing them down to all modules via `specialArgs` and `extraSpecialArgs`.
* **Fallbacks:** The flake contains logic to provide default values (e.g., for catppuccin) if a host does not explicitly define them.
* **Formatter:** Defines `nixfmt-rfc-style` as the default formatter for `nix fmt`.

## 🖥️ Hosts (`hosts/`)
Each folder corresponds to a machine managed by this flake.

### `local-packages.nix`
Since macOS applications and needs vary by machine (e.g., a work laptop vs. a personal MacBook), this file allows installing packages *only* for that specific machine without polluting the global configuration.