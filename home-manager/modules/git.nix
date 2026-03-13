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

      # Claude code
      "*.jsonl"
      ".claude.json"
      ".claude.json.backup.*"
      ".credentials.json"
      "credentials.json"
      "security_warnings_*.json"
      "worktrees/" 
      "**/.claude/*"
      "!**/.claude/agents/"
      "!**/.claude/agent-memory/"
      "!**/.claude/settings.json"
      "!**/.claude/statusline-commands.sh"
    ];

    settings = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };
}
