{
  lib,
  profile,
  config,
  ...
}:
let
  cfg = config.specialisations;
  inherit (lib) types;
in
{
  options.specialisations = {
    enable = lib.mkOption {
      type = types.bool;
      default = profile == "desktop";
    };
    niri = lib.mkOption {
      type = types.bool;
      default = cfg.enable;
    };
    hyprland = lib.mkOption {
      type = types.bool;
      default = cfg.enable;
    };
    sway = lib.mkOption {
      type = types.bool;
      default = cfg.enable;
    };
    gnome = lib.mkOption {
      type = types.bool;
      default = cfg.enable;
    };
    cosmic = lib.mkOption {
      type = types.bool;
      default = cfg.enable;
    };
    plasma = lib.mkOption {
      type = types.bool;
      default = cfg.enable;
    };
  };

  config.specialisation = lib.mkIf cfg.enable {
    "niri".configuration = {
      programs.niri.enable = true;
      environment.etc."specialisation".text = "niri";
    };
    "hyprland".configuration = {
      programs.hyprland.enable = true;
      environment.etc."specialisation".text = "hyprland";
    };
    "sway".configuration = {
      programs.sway.enable = true;
      environment.etc."specialisation".text = "sway";
    };
    "gnome".configuration = {
      services.desktopManager.gnome.enable = true;
      environment.etc."specialisation".text = "gnome";
    };
    "cosmic".configuration = {
      services.desktopManager.cosmic.enable = true;
      environment.etc."specialisation".text = "cosmic";
    };
    "plasma".configuration = {
      services.desktopManager.plasma6.enable = true;
      qt.platformTheme = lib.mkForce "kde";
      environment.etc."specialisation".text = "plasma";
    };
  };
}
