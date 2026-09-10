# Faithful port of tmux/.tmux.conf. Differences from that file are limited to
# things TPM used to do (plugin fetching) and three settings the old config
# never had but should have: a large scrollback, 1-based windows, and a short
# escape-time so vi mode does not lag.
#
# Not carried over: the TPM bootstrap lines (`set -g @plugin`, `run '~/.tmux/
# plugins/tpm/tpm'`, the explicit resurrect run-shell). programs.tmux.plugins
# fetches and sources all of it from the store instead.
{ pkgs, ... }:

let
  # tmux runs `#(...)` through /bin/sh with the server's PATH, which is not
  # guaranteed to have git. Wrapping pins it.
  gitStatus = pkgs.writeShellApplication {
    name = "tmux-git-status";
    runtimeInputs = [ pkgs.git pkgs.gnused ];
    text = builtins.readFile ./git-status.sh;
  };
in
{
  programs.tmux = {
    enable = true;
    prefix = "C-s";
    mouse = true;
    keyMode = "vi";
    terminal = "screen-256color";

    # Not in the old .tmux.conf; deliberate improvements.
    baseIndex = 1;
    escapeTime = 10;
    historyLimit = 50000;

    plugins = with pkgs.tmuxPlugins; [
      resurrect
      vim-tmux-navigator
      {
        plugin = rose-pine;
        # Must be set before the plugin sources itself, which is exactly what
        # this attrset form guarantees.
        extraConfig = ''
          set -g @rose_pine_variant 'main'

          # Transparent bar blends with terminal background
          set -g @rose_pine_bar_bg_disable 'on'
          set -g @rose_pine_bar_bg_disabled_color_option 'default'

          set -g @rose_pine_disable_active_window_menu 'on'
          set -g @rose_pine_show_current_program 'off'
          set -g @rose_pine_show_pane_directory 'off'
          set -g @rose_pine_directory 'on'
          set -g @rose_pine_date_time '%H:%M'
          set -g @rose_pine_user 'off'
          set -g @rose_pine_host 'off'

          # Nerd font separators
          set -g @rose_pine_left_separator '  '
          set -g @rose_pine_right_separator '''
          set -g @rose_pine_field_separator ' | '
          set -g @rose_pine_window_separator ' - '

          # Git branch in status bar
          set -g @rose_pine_status_right_prepend_section '#(${gitStatus}/bin/tmux-git-status #{pane_current_path})'

          # Window prioritization wipes the right side
          set -g @rose_pine_prioritize_windows 'off'
        '';
      }
    ];

    extraConfig = ''
      set -ga terminal-overrides ",*256col*:Tc"

      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      # Resize panes (repeatable: hold prefix once, mash H/J/K/L)
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 2
      bind -r K resize-pane -U 2
      bind -r L resize-pane -R 5

      # Binds Meta+l to `clear`
      bind-key -n M-l send-keys C-l

      # Split window into panels (2 top 80%, 2 bottom 20%)
      bind-key q split-window -v -p 40 -c "#{pane_current_path}" \; split-window -h -p 50 -c "#{pane_current_path}" \; select-pane -t 0 \; split-window -h -p 50 -c "#{pane_current_path}" \; select-pane -t 0
      bind-key a split-window -v -p 40 -c "#{pane_current_path}" \; split-window -h -p 50 -c "#{pane_current_path}" \; select-pane -t 0 \; select-pane -t 0
      # Split into 3 panes: left 60%, right split (top 70%, bottom 30%)
      bind-key v split-window -h -p 40 -c "#{pane_current_path}" \; select-pane -t 1 \; split-window -v -p 30 -c "#{pane_current_path}" \; select-pane -t 0

      set-option -g status-position top

      # Show the window name you set (C-s ,), not the running program
      set -g automatic-rename off

      # Refresh the status line every second
      set -g status-interval 1
    '';
  };
}
