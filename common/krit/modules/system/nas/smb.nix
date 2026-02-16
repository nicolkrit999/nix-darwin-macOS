{
  config,
  pkgs,
  vars,
  lib,
  ...
}:

let
  nasIP = "100.101.189.91";
  # Comm-5. NAS credentials
  credentialsFile = config.sops.secrets.nas-krit-credentials.path;

  # List of SMB shares
  shares = [
    "Amministrazione-NAS"
    "Default-volume-1"
    "Default-volume-2"
    "docker"
    "Famiglia"
    "Krit SD 512"
    "Momentary-volume-1"
    "personal_folder"
  ];

  # macOS Read-Only Root workaround: Mount to user home
  mountBase = "/Volumes/nicol_nas/smb";

  # Helper script to mount a single share
  mountScript = ''
    # 1. Load Credentials (parse standard smb credentials file)
    # Expects format: username=x \n password=y
    if [ -f "${credentialsFile}" ]; then
      source "${credentialsFile}"
    else
      echo "Credentials file not found!"
      exit 1
    fi

    # 2. Function to mount
    do_mount() {
      SHARE=$1
      MOUNTPOINT="${mountBase}/$SHARE"
      
      mkdir -p "$MOUNTPOINT"
      
      # Check if already mounted
      if ! mount | grep -q "$MOUNTPOINT"; then
        echo "Mounting $SHARE..."
        # Use native mount_smbfs. 
        # WARNING: Putting pass in URL is visible in process list, but simplest for automation without Keychain.
        mount_smbfs "//''${username}:''${password}@${nasIP}/$SHARE" "$MOUNTPOINT"
      fi
    }

    # 3. Mount all shares
    ${builtins.concatStringsSep "\n" (map (s: ''do_mount "${s}"'') shares)}
  '';

in
{
  # ---------------------------------------------------------
  # 1. TAILSCALE
  # ---------------------------------------------------------
  services.tailscale.enable = lib.mkForce true;

  # ---------------------------------------------------------
  # 2. SOPS SECRETS
  # ---------------------------------------------------------
  sops.secrets.nas-krit-credentials = {
    sopsFile = ../../../../../common/krit/sops/krit-common-secrets-sops.yaml;
    owner = vars.user; # Ensure user can read it to source it
  };

  # ---------------------------------------------------------
  # 3. LAUNCHD AGENT (Replaces systemd mount + warmer)
  # ---------------------------------------------------------
  launchd.user.agents.smb-mounter = {
    serviceConfig = {
      Label = "com.krit.smb-mounter";
      RunAtLoad = true;
      # Run every 5 minutes to ensure mounts stay up (Auto-healing)
      StartInterval = 300;
      StandardOutPath = "/Users/${vars.user}/Library/Logs/smb-mounter.log";
      StandardErrorPath = "/Users/${vars.user}/Library/Logs/smb-mounter.err";
    };
    script = mountScript;
  };

  # Note: The "Warmer" logic is implicitly handled by macOS Spotlight/Finder
  # if you browse the folders, but you can add a separate script if strict caching is needed.
}
