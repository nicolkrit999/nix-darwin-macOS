{
  pkgs,
  vars,
  ...
}:
{
  programs.git = {
    enable = true;
    settings.user.name = vars.gitUserName;
    settings.user.email = vars.gitUserEmail;

    lfs.enable = true;

    ignores = [
      ".direnv/"
      ".venv/"
      "result"
      "*.swp"
      ".DS_Store"
    ];

    settings = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };
}
