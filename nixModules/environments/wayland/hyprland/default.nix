{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (config.window-manager.enable && config.window-manager.name == "Hyprland") {
    programs.hyprland.enable = true;
  };
}
