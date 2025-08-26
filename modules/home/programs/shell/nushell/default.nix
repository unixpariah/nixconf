{
  shell,
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf (shell == "nushell") {
    home = {
      packages = builtins.attrValues {
        inherit (pkgs)
          # nufmt is very WIP, idk why its even in nixpkgs
          #nufmt
          inshellisense
          ;
      };
      persist.files = [ ".config/nushell/history.txt" ];
    };
    programs = {
      nushell = {
        enable = true;
        package = pkgs.nushell;
        inherit (config.home) shellAliases;

        plugins = builtins.attrValues { inherit (pkgs.nushellPlugins) highlight; };

        configFile.text = ''
          let carapace_completer = {|spans|
              ${config.programs.carapace.package}/bin/carapace $spans.0 nushell ...$spans | from json
          }

          $env.config = {
            ls: {
              clickable_links: true
            }

            rm: {
              always_trash: true
            }

            show_banner: false
            edit_mode: "vi"

            completions: {
              algorithm: "fuzzy"
              case_sensitive: false
              quick: true
              partial: true
              sort: "smart"
              external: {
                enable: true
                max_results: 100
                completer: $carapace_completer
              }
            }
            cursor_shape: {
              vi_insert: line
              vi_normal: block
            }
            keybindings: [
              {
                name: completion_menu
                modifier: none
                keycode: tab
                mode: [vi_insert vi_normal]
                event: { send: menu name: completion_menu }
              },
            ]
            use_kitty_protocol: true
            render_right_prompt_on_last_line: false
          }
        '';

        extraEnv = ''
          $env.TRANSIENT_PROMPT_COMMAND = ">"
          $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
        '';
      };
      carapace.enable = true;
    };
  };
}
