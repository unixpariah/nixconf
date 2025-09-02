{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.hyprland;
in
{
  nix.settings = lib.mkIf cfg.enable {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };
}
