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

    shellAliases = {
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
      fmt-dry = "cd ${flakeDir} && nix fmt --check";

      # Utilities
      caff = "caffeinate";
      xcodeaccept = "sudo xcodebuild -license accept";
      changehosts = "sudo nvim /etc/hosts";
      cleardns = "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";
      fzf-prev = ''fzf --preview="cat {}"'';
      zlist = "zoxide query -l -s"; # List all zoxide entries with scores

      # Nix-Darwin Maintenance
      nixpush = "cd ~/nix-darwin-macOS/ && sudo darwin-rebuild switch --flake .#$(scutil --get LocalHostName)";
      cdnix = "cd ~/nix-darwin-macOS/";
      nfc = "cd ${flakeDir} && nix flake check"; # Check flake for errors
      swdry = "cd ${flakeDir} && nh os test --dry --ask"; # Dry run of nixos-rebuild switch

    };

    # -----------------------------------------------------
    # ⚙️ INIT SCRIPT
    # -----------------------------------------------------
    initContent = ''
       # 1. LOAD USER CONFIG
        if [ -f "$HOME/.zshrc_custom" ]; then
          source "$HOME/.zshrc_custom"
        fi

        # 2. TMUX AUTOSTART (Only in GUI)
        # Ensure we are in a GUI before starting tmux automatically
        if status is-interactive
        and not set -q TMUX
        # 'exec' replaces the shell so exiting tmux closes the window
        exec tmux new-session -A -s main
      end

      # 3. Mac/Nix Specific Additions
      export CASE_SENSITIVE="true"
      export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

      # 4. SSH Agent Logic
      if [ -z "$SSH_AUTH_SOCK" ]; then
        eval "$(ssh-agent -s)" >/dev/null
        if [ -f "$HOME/.ssh/id_ed25519" ]; then
          ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519" >/dev/null 2>&1 || true
        fi
      fi

      # 5. iTerm Integration
      if [ -f "$HOME/.iterm2_shell_integration.zsh" ]; then
        . "$HOME/.iterm2_shell_integration.zsh"
      fi
    '';
  };
}
