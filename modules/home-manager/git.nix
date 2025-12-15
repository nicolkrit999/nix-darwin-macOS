{ gitUserName, gitUserEmail, ... }:
{
  programs.git = {
    enable = true;

    settings.user.name = gitUserName; # Your public display name on commits
    settings.user.email = gitUserEmail; # Email linked to GitHub/GitLab

    # Optional: Enable Git credential helper if using HTTPS
    # extraConfig = { credential.helper = "store"; };
  };
}
