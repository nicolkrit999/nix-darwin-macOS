{
  config,
  lib,
  pkgs,
  ...
}:

let
  # ---------------------------------------------------------
  # 🔧 VARIABLES
  # ---------------------------------------------------------
  nasUser = "krit";
  nasHost = "nicol-nas"; # Tailscale MagicDNS

  # Ensure hostname is set, otherwise default to a placeholder
  hostName = config.networking.hostName;

  # Path on the NAS
  nasPath = "/volume1/Default-volume-1/0001_Docker/borgitory/${hostName}";

  # ---------------------------------------------------------
  # 🔑 SECRETS (SOPS)
  # ---------------------------------------------------------
  passphraseFile = config.sops.secrets.borg-passphrase.path;
  sshKeyPath = config.sops.secrets.borg-private-key.path;

  # ---------------------------------------------------------
  # 🚫 EXCLUSIONS
  # ---------------------------------------------------------
  excludes = [
    # Security
    "/Users/krit/.config/borg-secrets"
    "/Users/krit/.ssh"

    # Junk
    "**/.DS_Store"
    "**/.stfolder*"
    "**/.stignore"
    "**/.localized"

    # Caches
    "*/Code Cache"
    "*/GPUCache"
    "*/DawnWebGPUCache"
    "*/DawnGraphiteCache"
    "*/Session Storage"
    "*/blob_storage"
    "*/PersistentCache"
    "*/.cache"
    "/Users/krit/Library/Caches"

    # File types
    "*.log"
    "*.tmp"
    "*.bak"
    "*.sock"
    "*.vdi"
    "*.qcow2"
    "*.iso"
    "*.vmwarevm"

    # Heavy Folders
    "/Users/krit/Library" # Be careful excluding entire Library on macOS!
    "/Users/krit/Applications"
    "/Users/krit/Downloads"
    "/Users/krit/Public"
    "/Users/krit/Music"
    "/Users/krit/Movies"
    "/Users/krit/Pictures/Photos Library.photoslibrary"
    "/Users/krit/Pictures/Photo Booth Library"
    "/Users/krit/Documents/Actual"

    # Dev & Repos
    "/Users/krit/nixOS"
    "/Users/krit/nix-darwin-macOS"
    "/Users/krit/dotfiles"
    "/Users/krit/developing-projects"
    "/Users/krit/tools"
    "/Users/krit/.nix-defexpr"
    "/Users/krit/.nix-profile"
    "/Users/krit/.local"
    "/Users/krit/.npm"
    "/Users/krit/.m2"
    "/Users/krit/.gradle"
    "/Users/krit/.cargo"
    "/Users/krit/.vscode"
    "/Users/krit/.mozilla"

    # App Configs (Regeneratable via Nix/Dotfiles)
    "/Users/krit/.config/raycast"
    "/Users/krit/.config/kitty"
    "/Users/krit/.config/git"
    "/Users/krit/.config/nvim"
    "/Users/krit/.config/tmux"
    "/Users/krit/.config/alacritty"
    "/Users/krit/.config/bat"
    "/Users/krit/.config/stylix"
    "/Users/krit/.config/ranger"
    "/Users/krit/.config/fastfetch"
    "/Users/krit/.config/iterm2"
    "/Users/krit/.config/forge"
    "/Users/krit/.config/gdu"
    "/Users/krit/.config/gtk-3.0"
    "/Users/krit/.config/gtk-4.0"
    "/Users/krit/.config/blender"
    "/Users/krit/.config/starship.toml"
    "/Users/krit/.config/Code"
    "/Users/krit/.config/Cursor"
    "/Users/krit/.config/Vencord"

    # System Trash/Logs
    "/Users/krit/.Trash"
    "/Users/krit/.terminfo"
    "/Users/krit/.themes"
    "/Users/krit/.lazygit"
    "/Users/krit/.zcompdump"
    "/Users/krit/.zsh_sessions"
    "/Users/krit/.zsh_history"
    "/Users/krit/.histfile"
    "/Users/krit/.zshrc"
    "/Users/krit/.zshrc_custom"
    "/Users/krit/.zshenv"
    "/Users/krit/.Xresources"
    "/Users/krit/.gtkrc-2.0"
    "/Users/krit/.CFUserTextEncoding"
    "/Users/krit/com.visualstudio.code.tunnel.plist"
  ];
in
{
  # 1. Install Borgmatic
  environment.systemPackages = [ pkgs.borgmatic ];

  # 2. Generate Configuration File
  # On macOS, this links to /etc/borgmatic/config.yaml
  environment.etc."borgmatic/config.yaml".text = ''
    location:
      source_directories:
        - /Users/krit

      repositories:
        - path: ssh://${nasUser}@${nasHost}${nasPath}
          label: nas-repo

      exclude_patterns:
        ${builtins.concatStringsSep "\n        " (map (x: "- \"${x}\"") excludes)}

    storage:
      compression: auto,zstd
      archive_name_format: '{hostname}-{now}'
      encryption_passcommand: cat ${passphraseFile}

    retention:
      keep_daily: 7
      keep_weekly: 4
      keep_monthly: 6

    consistency:
      checks:
        - repository
        - archives

    # SSH Command: Use specific key, auto-accept new host keys (for first run), generous timeout
    ssh_command: ssh -i ${sshKeyPath} -o StrictHostKeyChecking=accept-new -o ConnectTimeout=30
  '';

  # 3. Define the Launchd Service (The Mac equivalent of Systemd)
  launchd.user.agents.borgmatic-backup = {
    serviceConfig = {
      Label = "com.borgmatic.backup";

      # Run on load? Yes, to catch up.
      RunAtLoad = true;

      # Performance settings
      LowPriorityIO = true;
      Nice = 5;

      # Env vars
      EnvironmentVariables = {
        BORG_PASSCOMMAND = "cat ${passphraseFile}";
        # Explicitly set PATH so it finds ssh, cat, etc.
        PATH = "${
          lib.makeBinPath [
            pkgs.borgmatic
            pkgs.openssh
            pkgs.coreutils
          ]
        }:/usr/bin:/bin:/usr/sbin:/sbin";
      };

      # The Command
      ProgramArguments = [
        "${pkgs.borgmatic}/bin/borgmatic"
        "--config"
        "/etc/borgmatic/config.yaml"
        "--syslog-verbosity"
        "1"
      ];

      # Schedule: 10am, 2pm, 10pm
      StartCalendarInterval = [
        {
          Hour = 10;
          Minute = 0;
        }
        {
          Hour = 14;
          Minute = 0;
        }
        {
          Hour = 22;
          Minute = 0;
        }
      ];

      StandardOutPath = "/Users/krit/Library/Logs/borgmatic.log";
      StandardErrorPath = "/Users/krit/Library/Logs/borgmatic.err";
    };
  };

  services.tailscale.enable = lib.mkForce true;

  sops.secrets.borg-passphrase = {
    owner = "krit";
  };
  sops.secrets.borg-private-key = {
    owner = "krit";
  };
}
