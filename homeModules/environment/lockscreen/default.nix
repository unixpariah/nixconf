{
  config,
  lib,
  system_type,
  ...
}:
let
  cfg = config.environment.lockscreen;
in
{
  options.environment.lockscreen.enable = lib.mkOption {
    type = lib.types.bool;
    default = system_type == "desktop";
  };

  config.programs.hyprlock = {
    enable = cfg.enable;
    settings = {
      general = {
        hide_cursor = true;
        grace = 2;
      };
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
}
