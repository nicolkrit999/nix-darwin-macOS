{ config, pkgs, ... }:

let
  # 📂 Define your Flake directory once for cleaner aliases
  flakeDir = "~/nix-darwin-macOS";
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    sessionVariables = {
      JAVA_HOME = "${pkgs.jdk25}";
      JDTLS_BIN = "${pkgs.jdt-language-server}/bin/jdtls";
    };

    shellAliases = {
      # -----------------------------------------------------
      # 🍎 MAC SPECIFIC ALIASES (Moved from home.nix)
      # -----------------------------------------------------
      brew-upd = "brew update && brew upgrade";
      brew-upd-res = "brew update-reset";
      brew-inst = "brew install";
      brew-inst-cask = "brew install --cask";
      brew-search = "brew search";
      brew-clean = "brew cleanup";
      sw = "nh darwin switch ${flakeDir}";
      upd = "cd ${flakeDir} && nix flake update && darwin-rebuild switch --flake ${flakeDir}";

      hms = "home-manager switch --flake ${flakeDir}";

      pkgs = "nvim ${flakeDir}/home-manager/modules/default.nix";

      # 🧹 FORMATTING
      fmt = "cd ${flakeDir} && nix fmt -- **/*.nix"; # Format Nix files using nixfmt (a regular nix fmt hangs on zed theme)
      fmt-dry = "cd ${flakeDir} && nix fmt -- --check";

      # Utilities
      caff = "caffeinate";
      xcodeaccept = "sudo xcodebuild -license accept";
      changehosts = "sudo nvim /etc/hosts";
      cleardns = "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";

      # Nix-Darwin Maintenance
      nixpush = "cd ~/nix-darwin-macOS/ && sudo darwin-rebuild switch --flake .#$(scutil --get LocalHostName)";
      cdnix = "cd ~/nix-darwin-macOS/";

      # Modern Replacements
      cat = "bat";
      ls = "eza";
    };

    # -----------------------------------------------------
    # ⚙️ INIT SCRIPT (Your Exact Logic)
    # -----------------------------------------------------
    initContent = ''
      # 1. Source the GENERAL ZSHRC (The one you use on Linux)
      if [ -f "$HOME/dotfiles/general-zshrc/.zshrc_custom" ]; then
        source "$HOME/dotfiles/general-zshrc/.zshrc_custom"
      fi

      # 2. Mac/Nix Specific Additions
      export CASE_SENSITIVE="true"
      export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

      # SSH Agent Logic
      if [ -z "$SSH_AUTH_SOCK" ]; then
        eval "$(ssh-agent -s)" >/dev/null
        if [ -f "$HOME/.ssh/id_ed25519" ]; then
          ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519" >/dev/null 2>&1 || true
        fi
      fi

      # iTerm Integration
      if [ -f "$HOME/.iterm2_shell_integration.zsh" ]; then
        . "$HOME/.iterm2_shell_integration.zsh"
      fi
    '';
  };
}
