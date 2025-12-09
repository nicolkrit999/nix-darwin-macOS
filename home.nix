{ pkgs, lib, ... }:

{
  home.username = "krit";
  home.homeDirectory = "/Users/krit";
  home.stateVersion = "25.11";

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

    # Using initContent as requested
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
      # VMUP FUNCTION (Bootstrap Mode)
      # -----------------------------------------------------------------------
      vmup() {
        local DATA_DIR="$HOME/nixos-vm-data"
        local IMAGE_URL="https://channels.nixos.org/nixos-25.11/latest-nixos-minimal-aarch64-linux.iso"
        
        mkdir -p "$DATA_DIR"
        cd "$DATA_DIR" || return

        # 1. Detect Hostname & Set Hardware Specs
        local HOST
        HOST=$(scutil --get LocalHostName)
        local MEMORY="4G"
        local CORES="2"
        local DISK_SIZE="64G"

        if [ "$HOST" = "MacBook-Air-di-Roberta" ]; then
          MEMORY="3G"; CORES="2"; DISK_SIZE="64G"
        elif [ "$HOST" = "Krits-MacBook-Pro" ]; then
          MEMORY="12G"; CORES="6"; DISK_SIZE="128G"
        fi

        # 2. Create Disk
        local DISK_IMG="nixos-disk.qcow2"
        if [ ! -f "$DISK_IMG" ]; then
          echo "📦 Creating virtual hard drive ($DISK_SIZE)..."
          qemu-img create -f qcow2 "$DISK_IMG" "$DISK_SIZE"
        fi

        # 3. Download ISO
        local ISO_IMG="nixos-minimal.iso"
        if [ ! -f "$ISO_IMG" ]; then
           echo "⬇️  Downloading NixOS Installer ISO..."
           curl -L -o "$ISO_IMG" "$IMAGE_URL"
        fi

        echo "🚀 Starting NixOS VM..."
        echo "   Host: $HOST"
        echo "   Specs: $MEMORY RAM / $CORES Cores"
        
        # 4. Run QEMU
        # -device virtio-gpu-pci: Better graphics for Hyprland
        # -device usb-tablet: Fixes mouse synchronization
        # -cdrom: REMOVE THIS LINE AFTER INSTALLING!
        qemu-system-aarch64 \
          -machine virt,accel=hvf,highmem=off \
          -cpu host \
          -smp "$CORES" \
          -m "$MEMORY" \
          -drive file="$DISK_IMG",if=virtio,format=qcow2 \
          -cdrom "$ISO_IMG" \
          -device virtio-gpu-pci \
          -device usb-ehci -device usb-tablet \
          -nic user,model=virtio \
          -serial stdio
      }

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

    # VM Management
    vmstop   = "pkill qemu-system-aarch64";
    
    # Nix-darwing specific
    cdnix = "cd ~/nix-config/";
    nixpush = "cd ~/nix-darwin-macOS/ && sudo nix run nix-darwin -- switch --flake \".#$(scutil --get LocalHostName)\"";
  };
}
