{
  pkgs,
  inputs,
  lib,
  hostname,
  pkgs-stable,
  config,
  std,
  ...
}:
let
  username = "unixpariah"; # Temporary
in
{
  imports = [ ./environments ];

  specialisation = {
    Hyprland.configuration = {
      window-manager = {
        enable = true;
        name = "Hyprland";
        backend = "Wayland";
      };
      environment.etc."specialisation".text = "Hyprland";
    };
    sway.configuration = {
      window-manager = {
        enable = true;
        name = "sway";
        backend = "Wayland";
      };
      environment.etc."specialisation".text = "sway";
    };
    niri.configuration = {
      window-manager = {
        enable = true;
        name = "niri";
        backend = "Wayland";
      };
      environment.etc."specialisation".text = "niri";
    };
    i3.configuration = {
      window-manager = {
        enable = true;
        name = "i3";
        backend = "X11";
      };
      environment.etc."specialisation".text = "i3";
    };
  };

  home-manager = {
    useUserPackages = true;
    backupFileExtension = "bak";
    extraSpecialArgs = {
      inherit
        inputs
        hostname
        pkgs
        pkgs-stable
        username
        std
        ;
    };
    users."${username}" = {
      options = {
        outputs = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                position = {
                  x = lib.mkOption { type = lib.types.int; };
                  y = lib.mkOption { type = lib.types.int; };
                };
                refresh = lib.mkOption { type = lib.types.float; };
                dimensions = {
                  width = lib.mkOption { type = lib.types.int; };
                  height = lib.mkOption { type = lib.types.int; };
                };
                scale = lib.mkOption {
                  type = lib.types.int;
                  default = 1;
                };
              };
            }
          );
          default = { };
        };
        font = lib.mkOption { type = lib.types.str; };
        email = lib.mkOption { type = lib.types.str; };
      };
      imports = [
        ./tools
        ./gaming
        ./gui
        ./colorschemes.nix
        ./security
        ./network
        ./system
        inputs.impermanence.homeManagerModules.default
        inputs.sops-nix.homeManagerModules.sops
        inputs.seto.homeManagerModules.default
      ];
      config = {
        programs.home-manager.enable = true;
        home = {
          packages = with pkgs; [
            just
            nvd
            nix-output-monitor
            # (writeShellScriptBin "shell" ''
            #   nix develop "${std.dirs.config}#devShells.$@.${pkgs.system}" -c ${
            #     config.home-manager.users.${username}.shell
            #   }
            # '')
            (writeShellScriptBin "specialisation" ''cat /etc/specialisation'')
            (writeShellScriptBin "nb" ''
              command "$@" > /dev/null 2>&1 &
              disown
            '')
          ];
          username = "${username}";
          stateVersion = config.system.stateVersion;
        };
      };
    };
  };
}
