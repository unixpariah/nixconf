{
  pkgs,
  lib,
  profile,
  ...
}:
{
  imports = [
    ./hyprland
    ./sway
    ./niri
    ./gnome
  ];

  config = lib.mkIf (profile == "desktop") {
    home = {
      packages =
        if pkgs.lib.onGnome then
          builtins.attrValues { inherit (pkgs) wlr-randr wl-clipboard-rs; }
        else
          builtins.attrValues { inherit (pkgs) wl-clipboard; };
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        WLR_NO_HARDWARE_CURSORS = "1";
      };
    };
  };
}
