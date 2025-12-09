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
      
      # -----------------------------------------------------------------------
      # VMUP FUNCTION
      # (Defined as a function instead of an alias to handle the logic safely)
      # -----------------------------------------------------------------------
      vmup() {
        # 1. Define where the VM disk should live (Outside the repo!)
        local VM_DATA_DIR="$HOME/nixos-vm-data"
        local FLAKE_DIR="$HOME/nix-darwin-macOS"
  
        # 2. Create directory if missing and enter it
        mkdir -p "$VM_DATA_DIR"
        cd "$VM_DATA_DIR" || return
  
        # 3. Detect Hostname
        local HOST
        HOST=$(scutil --get LocalHostName)
        local VM_NAME=""
        
        if [ "$HOST" = "MacBook-Air-di-Roberta" ]; then
          VM_NAME="mac-book-air-roberta-nixos-vm"
        elif [ "$HOST" = "Krits-MacBook-Pro" ]; then
          VM_NAME="mac-book-pro-krit-nixos-vm"
        else
          echo "❌ Unknown host for VM mapping" 
          return 1
        fi
  
        echo "🚀 Starting NixOS VM for host: $HOST"
        echo "📂 Storage Location: $VM_DATA_DIR"
        
        # 4. Run the VM referencing the flake directory
        nix run "$FLAKE_DIR#nixosConfigurations.$VM_NAME.config.system.build.vm"
      }
    '';
  };

  programs.command-not-found.enable = false;

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

    # VM Management (Simple commands)
    vmstop   = "pkill qemu-system-aarch64";

    # Nix-darwin specific
    cdnix = "cd ~/nix-config/";
    nixpush = "cd ~/nix-darwin-macOS/ && sudo nix run nix-darwin -- switch --flake \".#$(scutil --get LocalHostName)\"";
  };
}
