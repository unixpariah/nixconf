{
  username,
  pkgs,
  ...
}: {
  home-manager.users."${username}".programs.tmux = {
    enable = true;
    aggressiveResize = true;
    baseIndex = 1;
    clock24 = true;
    keyMode = "vi";
    prefix = "C-space";
    newSession = true;
    secureSocket = true;
    sensibleOnTop = true;
    escapeTime = 0;
    terminal = "screen-256color";
    plugins = with pkgs.tmuxPlugins; [
      yank
      sensible
      vim-tmux-navigator
      catppuccin
    ];
    extraConfig = ''
      set -g @plugin 'dreamsofcode-io/catppuccin-tmux'

      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key x kill-pane

      bind - split-window -v -c "#{pane_current_path}"
      bind | split-window -h -c "#{pane_current_path}"

      set -g renumber-windows on
      set-option -g automatic-rename off
      set-window-option -g window-status-format "#I:#W#F"
      set-window-option -g window-status-current-format "#[bold]#I:#W#F"
      bind-key C-b run-shell "tmux rename-window "$(basename $(pwd))""

      run '~/.config/tmux/plugins/tpm/tpm'
    '';
  };
}