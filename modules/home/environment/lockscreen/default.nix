{
  config,
  lib,
  profile,
  platform,
  pkgs,
  ...
}:
let
  cfg = config.environment.lockscreen;
  inherit (lib) types;
in
{
  options.environment.lockscreen = {
    enable = lib.mkOption {
      type = types.bool;
      default = profile == "desktop";
    };
    package = lib.mkOption {
      type = types.package;
      default = if platform == "non-nixos" then config.lib.nixGL.wrap pkgs.hyprlock else pkgs.hyprlock;
    };
  };

  config = {
    programs.hyprlock = {
      inherit (cfg) enable;
      inherit (cfg) package;
      settings = {
        general.hide_cursor = true;
        label = [
          {
            monitor = "";
            text = "$TIME";
            font_size = 100;
            position = "0, 80";
            valign = "center";
            halign = "center";
          }
        ];

        input-field = {
          size = "50, 50";
          dots_size = 0.33;
          dots_spacing = 0.15;
        };
      };
    };
  };
}
