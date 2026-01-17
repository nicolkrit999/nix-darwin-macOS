{
  config,
  pkgs,
  vars,
  lib,
  ...
}:

let
  nasUser = "root";
  nasHost = "100.101.189.91"; # Tailscale IP

  # macOS Path
  mountPoint = "/Volumes/nicol_nas/ssh/system_root";

  identityFile = config.sops.secrets.nas_ssh_key.path;
in
{
  environment.systemPackages = [ pkgs.sshfs ];
  services.tailscale.enable = lib.mkForce true;

  # ---------------------------------------------------------
  # 🔐 SOPS
  # ---------------------------------------------------------
  sops.secrets.nas_ssh_key = {
    sopsFile = ../../../../../common/krit-common-secrets-sops.yaml;
    owner = vars.user;
    mode = "0600";
  };

  # ---------------------------------------------------------
  # 🚀 LAUNCHD AGENT (Replaces systemd mount)
  # ---------------------------------------------------------
  launchd.user.agents.sshfs-nas = {
    serviceConfig = {
      Label = "com.krit.sshfs-nas";
      RunAtLoad = true;
      KeepAlive = true; # Restart if connection drops
      StandardOutPath = "/Users/${vars.user}/Library/Logs/sshfs-nas.log";
      StandardErrorPath = "/Users/${vars.user}/Library/Logs/sshfs-nas.err";

      # Environment variables for the script
      EnvironmentVariables = {
        PATH = "${
          lib.makeBinPath [
            pkgs.sshfs
            pkgs.coreutils
          ]
        }:/usr/bin:/bin";
      };
    };

    script = ''
      mkdir -p "${mountPoint}"

      # Unmount if stale
      umount "${mountPoint}" || true

      # Mount
      # -f: run in foreground (required for launchd KeepAlive)
      # -o reconnect: vital for network mounts
      sshfs ${nasUser}@${nasHost}:/ "${mountPoint}" \
        -f \
        -o IdentityFile="${identityFile}" \
        -o reconnect \
        -o ServerAliveInterval=15 \
        -o StrictHostKeyChecking=accept-new \
        -o Compression=yes \
        -o volname="NAS_Root"
    '';
  };
}
