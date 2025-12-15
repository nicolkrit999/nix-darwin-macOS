{
  pkgs,
  gitUserName, # Passed from flake.nix
  gitUserEmail, # Passed from flake.nix
  ...
}:
{
  programs.git = {
    enable = true;
    settings.user.name = gitUserName;
    settings.user.email = gitUserEmail;

    settings = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };
}
