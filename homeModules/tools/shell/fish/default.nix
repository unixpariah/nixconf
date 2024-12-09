{
  config,
  lib,
  shell,
  ...
}:
let
  inherit (config) colorscheme;
in
{
  config = lib.mkIf (shell == "fish") {
    impermanence.persist.directories = [ ".local/share/fish" ];
    programs.fish = {
      enable = true;
      functions = {
        fish_mode_prompt = {
          body =
            let
              inherit (colorscheme) special error;
            in
            ''
              switch $fish_bind_mode
                case default
                  echo -en "\e[2 q"
                  set_color -o ${error}
                  echo " [N]"
                case insert
                  echo -en "\e[6 q"
                  set_color -o ${special}
                  echo " [I]"
                end
                set_color normal
            '';
        };
        fish_prompt = {
          body =
            let
              inherit (colorscheme) accent1 accent2;
            in
            ''
              echo -s ' '(set_color ${accent2} --bold)(basename (prompt_pwd)) (set_color ${accent2} --bold) (fish_git_prompt " git:("(set_color FAB387 --bold)"%s"(set_color ${accent2} --bold)")") (set_color ${accent1} --bold)'  '
            '';
        };
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
