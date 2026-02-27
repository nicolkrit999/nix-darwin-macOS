{
  pkgs,
  pkgs-unstable,
  lib,
  vars,
  ...
}:

{

  # -----------------------------------------------------------------------
  # 🔗 IMPORTS
  # -----------------------------------------------------------------------
  # Pulls in all individual program modules
  imports = [
    # Common home-manager krit modules
    ../../common/krit/modules/home-manager

    # use-cases home-manager modules
    ../../common/krit/modules/use-cases/home-imports.nix

    # Architecture specific home-packages
    ../../common/krit/packages/default.nix

    # Local Host Modules
    ./optional/general-hm-modules
    ./optional/host-hm-modules
  ];

  home.packages =
    (with pkgs; [

      # -----------------------------------------------------------------------------------
      # 🖥️ DESKTOP APPLICATIONS
      # -----------------------------------------------------------------------------------
      vscode # IDE
      ranger # Terminal file manager

      # -----------------------------------------------------------------------------------
      # 🖥️ CLI UTILITIES
      # -----------------------------------------------------------------------------------
      killall # Command to kill processes by name
      nix-search-cli # CLI tool to search nixpkgs from terminal
      ripgrep # Fast line-oriented search tool
      unzip # Extraction utility for .zip files (used by mason in neovim)
      zip # Compression utility for .zip files (used by mason in neovim)
      zlib # Compression utility for .zip files (used by mason in neovim)
      wget # Network downloader utility
    ])

    ++ (with pkgs-unstable; [
    ]);

  home.sessionVariables = {
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = vars.shell == "zsh";
    enableFishIntegration = vars.shell == "fish";
    enableBashIntegration = vars.shell == "bash";
  };

  # 5. Create/remove host-specific directories
  home.activation = {
    createHostDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p $HOME/Pictures/wallpapers
      mkdir -p $HOME/momentary
    '';
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."github.com" = {
      identityFile = "/Users/${vars.user}/.ssh/id_github";
    };
  };

  # 6. PGP agent configuration
  programs.git = {
    enable = true;

    # Configure signing specifically using Home Manager's options
    signing = {
      key = "D93A24D8E063EECF";
      signByDefault = true;
    };
    settings = {
      gpg.program = "/etc/profiles/per-user/${vars.user}/bin/gpg";
    };
  };

  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    enableZshIntegration = true;
    # specific to macOS
    pinentry.package = pkgs.pinentry_mac;
  };

}
