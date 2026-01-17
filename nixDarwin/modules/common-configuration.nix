{ pkgs, vars, ... }:
let
  shellPkg =
    if vars.shell == "fish" then
      pkgs.fish
    else if vars.shell == "zsh" then
      pkgs.zsh
    else
      pkgs.bashInteractive;
in
{
  # ---------------------------------------------------
  # 1. SYSTEM SETTINGS & DEFAULTS
  # ---------------------------------------------------
  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
  };

  # Enable Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  networking.hostName = vars.hostname;
  networking.computerName = vars.hostname;
  system.stateVersion = vars.darwinStateVersion;

  home-manager.backupFileExtension = "hm-backup";

  # Build users group ID (from your old config)
  ids.gids.nixbld = 350;

  nix.enable = true;
  environment.systemPackages = (
    with pkgs;
    [
      # Packages in each category are sorted alphabetically

      # -----------------------------------------------------------------------------------
      # -----------------------------------------------------------------------------------
      #  ⚠️ START APPLICATIONS TO KEEP HERE BLOCK ⚠️

      # -----------------------------------------------------------------------------------
      # 🖥️ DESKTOP APPLICATIONS
      # -----------------------------------------------------------------------------------

      # -----------------------------------------------------------------------------------
      # 🖥️ CLI UTILITIES
      # -----------------------------------------------------------------------------------
      # Lightweight video thumbnailer (needed for ranger video previews) -> ⚠️ KEEP
      ffmpegthumbnailer
      fzf # Command-line fuzzy finder (ls zhs aliases depend on this) -> ⚠️ KEEP
      htop # Interactive process viewer (keep to kill processes easily) -> ⚠️ KEEP
      nh # CLI help for Nix package management (used in zsh.nix) -> ⚠️ KEEP
      stow # Dotfile symlikn manager -> ⚠️ KEEP
      ueberzugpp # Image previews for terminal (used by Ranger backend) -> ⚠️ KEEP
      nixfmt-rfc-style # Nix code formatter with RFC style (used in flake.nix) -> ⚠️ KEEP
      sops # Secret management tool -> ⚠️ KEEP
      shellPkg # User shell (zsh, fish, bash) -> ⚠️ KEEP
      age # Encryption tool used by sops -> ⚠️ KEEP

      # -----------------------------------------------------------------------------------
      # 🧑🏽‍💻 CODING
      # -----------------------------------------------------------------------------------
      vscode # Code editor (in my machine it would not installed if put in local-packages.nix) -> ⚠️ KEEP

      # -----------------------------------------------------------------------
      # ❓ OTHER
      # -----------------------------------------------------------------------
      nix-prefetch-scripts # Nix dev tools

      #  ⚠️ END APPLICATIONS TO KEEP HERE BLOCK ⚠️
      # -----------------------------------------------------------------------------------
      # -----------------------------------------------------------------------------------

      # -----------------------------------------------------------------------------------
      # -----------------------------------------------------------------------------------
      #  ⭐ START OF OTHER APPLICATION ⭐
      # -----------------------------------------------------------------------------------

      # -----------------------------------------------------------------------------------
      # 🖥️ DESKTOP APPLICATIONS
      # -----------------------------------------------------------------------------------

      # -----------------------------------------------------------------------------------
      # 🖥️ CLI UTILITIES
      # -----------------------------------------------------------------------------------

      # -----------------------------------------------------------------------------------
      # 🧑🏽‍💻 CODING
      # -----------------------------------------------------------------------------------
      # Java Development Kit (needed for some Neovim LSP servers) -> ⚠️ KEEP

      # -----------------------------------------------------------------------------------
      # 😂 FUN PACKAGES
      # -----------------------------------------------------------------------------------

      # -----------------------------------------------------------------------
      # ❓ OTHER
      # -----------------------------------------------------------------------

      #  ⭐ END OF OTHER APPLICATION ⭐
      # -----------------------------------------------------------------------------------
      # -----------------------------------------------------------------------------------

    ]
  );

  # ---------------------------------------------------------
  # 🐚 SHELLS & ENVIRONMENT
  # ---------------------------------------------------------

  environment.systemPath = [
    "/nix/var/nix/profiles/per-user/${vars.user}/profile/bin"
  ];

  environment.shells = [ shellPkg ];
  users.knownUsers = [ vars.user ];

  users.users.${vars.user} = {
    shell = shellPkg;
    uid = 501;
  };

  programs.zsh.enable = true;
  programs.zsh.interactiveShellInit =
    if vars.shell == "fish" then
      ''
        # Bash/Zsh syntax:
        if [[ $(ps -o command= -p "$PPID" | awk '{print $1}') != 'fish' ]]; then
          exec ${pkgs.fish}/bin/fish -l
        fi
      ''
    else
      "";

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Fish syntax:
      if status is-interactive
        and not set -q TMUX
        exec tmux new-session -A -s main
      end
    '';
  };

}
