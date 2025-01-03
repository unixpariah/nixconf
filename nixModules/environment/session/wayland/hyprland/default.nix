{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.environment;
in
{
  config = lib.mkIf (cfg.session == "Wayland") {
    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };

    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    };
  };
}
