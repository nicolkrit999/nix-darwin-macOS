{ pkgs, user, ... }:
{
  # ------------------------------------------------------
  # 🖥️ HOST-SPECIFIC PACKAGES (Krits-MacBook-Pro)
  # ------------------------------------------------------
  users.users.${user}.packages = with pkgs; [
    # ----------------------------------------------------
    # 🍎 Mac Specific Utilities
    # ----------------------------------------------------
    # (Add things here that you ONLY want on this laptop)

    # Example:
    # m-cli        # Mac CLI tools
    # dockutil     # Dock management

    # ----------------------------------------------------
    # 🚀 Shared Tools (overrides or extras)
    # ----------------------------------------------------
    # You can duplicate tools here if you want them strictly
    # on this machine and not globally.
  ];
}
