{
  config,
  pkgs,
  inputs,
  ...
}: let
  inherit (config) shell username browser term;
in {
  imports = [
    (import ./environments/wayland/default.nix {inherit inputs pkgs;})
    (import ./security/default.nix {inherit inputs username;})
    (import ./gui/default.nix {inherit inputs username pkgs browser;})
    (import ./tools/default.nix {inherit config inputs pkgs;})
    (import ./system/default.nix {inherit pkgs config;})
    (import ./hardware/default.nix {inherit config;})
    (import ./network/default.nix {inherit config pkgs inputs;})
    ./docs/default.nix
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowUnfree = true;

  users.users."${config.username}" = {
    isNormalUser = true;
    extraGroups = ["wheel"];
  };

  home-manager.users."${username}" = {
    home = {
      username = "${username}";
      homeDirectory = "/home/${username}";
      stateVersion = "23.11";
    };
    programs = {
      home-manager.enable = true;
      direnv = {
        enable = true;
        enableBashIntegration = true;
        nix-direnv.enable = true;
      };
    };
  };

  specialisation = {
    Hyprland = {
      configuration = {
        imports = [
          (import ./environments/wayland/hyprland/default.nix {inherit shell inputs pkgs username term;})
        ];
        environment.etc."specialisation".text = "Hyprland";
      };
    };
    Sway = {
      configuration = {
        services.xserver.videoDrivers = ["nouveau"];
        imports = [
          (import ./environments/wayland/sway/default.nix {inherit inputs shell pkgs username term;})
        ];
        environment.etc."specialisation".text = "Sway";
      };
    };
  };
}
