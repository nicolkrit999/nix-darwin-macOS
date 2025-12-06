{ pkgs, lib, ... }:

{
  home.username = "krit";
  home.homeDirectory = "/Users/krit";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  # Link jdtls so the general zshrc export works
  home.file."tools/jdtls".source = "${pkgs.jdt-language-server}";

  home.sessionVariables = {
    JAVA_HOME = "${pkgs.jdk25}";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Tell to add specific init code to a general zshrc stowed in dotfiles
    initContent = ''
      # REBUILD_TRIGGER: 1
      # 1. Source the GENERAL ZSHRC (The one you use on Linux)
      if [ -f "$HOME/dotfiles/general-zshrc/.zshrc" ]; then
        source "$HOME/dotfiles/general-zshrc/.zshrc"
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

  programs.command-not-found.enable = false;

  # ONLY Mac specific aliases here.
  home.shellAliases = {
    # Homebrew aliases
    brew-upd      = "brew update && brew upgrade";
    brew-upd-res  = "brew update-reset";
    brew-inst     = "brew install";
    brew-inst-cask= "brew install --cask";
    brew-search   = "brew search";
    brew-clean    = "brew cleanup";

    # Various mac specific utilities
    caff        = "caffeinate";
    xcodeaccept = "sudo xcodebuild -license accept";
    changehosts = "sudo nvim /etc/hosts";
    cleardns    = "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";

    # Nix-darwing specific
    cdnix = "cd /etc/nix-darwin/";
    nixpush = "cd /etc/nix-darwin/ && sudo nix run nix-darwin -- switch --flake \".#$(scutil --get LocalHostName)\"";
  };
}
