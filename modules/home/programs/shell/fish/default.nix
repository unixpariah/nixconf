{ lib, shell, ... }:
{
  config = lib.mkIf (shell == "fish") {
    home = {
      persist.directories = [ ".local/share/fish" ];
      shell.enableFishIntegration = true;
    };
    programs.fish = {
      enable = true;
      functions = {
        fish_vi_on_paging = {
          body = ''
            commandline -f complete
            if commandline --paging-mode
            commandline -f repaint
            set fish_bind_mode default
            end
          '';
        };
      };
      loginShellInit = ''
        fish_vi_key_bindings;

        bind --mode insert \t fish_vi_on_paging
      '';

      interactiveShellInit = ''
        bind --mode insert \t fish_vi_on_paging

        set -g fish_greeting ""
      '';
    };
  };
}
