{
  pkgs,
  lib,
  catppuccin,
  catppuccinFlavor,
  catppuccinAccent,
  ...
}:
{
  # -----------------------------------------------------------------------
  # 🎨 CATPPUCCIN THEME (Official Module)
  # -----------------------------------------------------------------------
  catppuccin.tmux.enable = catppuccin;
  catppuccin.tmux.flavor = catppuccinFlavor;

  # Only apply the "Rounded" status bar if using Catppuccin
  catppuccin.tmux.extraConfig = lib.mkIf catppuccin ''
    set -g @catppuccin_window_status_style "rounded"
    set -g @catppuccin_status_modules_right "directory session user host"

    # Optional: Use the accent color for the active window pill
    set -g @catppuccin_window_current_fill "${catppuccinAccent}"
  '';

  # -----------------------------------------------------------------------
  # 🧇 PROGRAM: TMUX
  # -----------------------------------------------------------------------
  programs.tmux = {
    enable = true;

    baseIndex = 1;
    mouse = true;
    escapeTime = 0;
    keyMode = "vi";
    terminal = "screen-256color";

    extraConfig = ''
      # True-color support for Alacritty
      set -as terminal-features ",alacritty*:RGB"

      # --- CUSTOM BINDINGS (Alt/Meta based) ---
      # "C" is "CTRL"
      # "M" is "ALT"
      # "S" is "SHIFT"
      bind -n M-r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!" # Reload config
      bind C-p previous-window 
      bind C-n next-window

      # Window Navigation
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-6 select-window -t 6
      bind -n M-7 select-window -t 7
      bind -n M-8 select-window -t 8
      bind -n M-9 select-window -t 9

      # Pane Navigation
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      # Resizing Panes
      bind -n M-S-Left resize-pane -L 5 # Left by 5 steps
      bind -n M-S-Right resize-pane -R 5 # Right by 5 steps
      bind -n M-S-Up resize-pane -U 3 # Up by 3 steps
      bind -n M-S-Down resize-pane -D 3 # Down by 3 steps

      # Splitting
      bind -n M-s split-window -v # Vertical split
      bind -n M-v split-window -h # Horizontal split

      # --- PRODUCTIVITY SHORTCUTS ---
      bind -n M-o new-window -c ~/para "nvim -c 'Telescope find_files' '0 Inbox/todolist.md'"
      bind -n M-f new-window -c ~/flake "nvim -c 'Telescope find_files' flake.nix"
      bind -n M-n new-window -c ~/.config/nvim "nvim -c 'Telescope find_files' init.lua"
      bind -n M-Enter new-window
      bind -n M-c kill-pane
      bind -n M-q kill-window
      bind -n M-Q kill-session
    '';

    plugins = with pkgs; [
      # plugins...
    ];
  };
}
