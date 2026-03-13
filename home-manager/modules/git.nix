{ pkgs
, vars
, ...
}:
{
  programs.git = {
    enable = true;
    settings.user.name = vars.gitUserName;
    settings.user.email = vars.gitUserEmail;

    lfs.enable = true;

    ignores = [
      # Virtual environments and direnv
      ".direnv/"
      ".venv/"

      # Nix build results
      "result"

      # Editor swap files and OS trash
      "*.swp"
      ".DS_Store"

      # Claude Code dynamic state & credentials
      ".claude/"
      "*.jsonl"
      ".claude.json"
      ".claude.json.backup.*"
      ".credentials.json"
      "credentials.json"
      "security_warnings_*.json"
    ];

    settings = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };
}
