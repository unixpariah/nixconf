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
  };

  config.specialisation = lib.mkIf cfg.enable {
    "niri".configuration = {
      programs.niri.enable = true;
      xdg.dataFile."home-manager/specialisation".text = "niri";
    };
    "hyprland".configuration = {
      programs.hyprland.enable = true;
      xdg.dataFile."home-manager/specialisation".text = "hyprland";
    };
    "sway".configuration = {
      programs.sway.enable = true;
      xdg.dataFile."home-manager/specialisation".text = "sway";
    };
    "gnome".configuration = {
      programs.gnome.enable = true;
      xdg.dataFile."home-manager/specialisation".text = "gnome";
    };
    "cosmic".configuration = {
      xdg.dataFile."home-manager/specialisation".text = "cosmic";
    };
    "plasma".configuration = {
      xdg.dataFile."home-manager/specialisation".text = "plasma";
    };
  };
}
