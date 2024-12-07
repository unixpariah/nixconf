{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hyprland
    ./sway
    ./niri
  ];

  config = lib.mkIf (config.window-manager.enable && config.window-manager.backend == "Wayland") {
    environment = {
      loginShellInit =
        # bash
        ''
          if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
          ${
            (
              if config.window-manager.name == "sway" then
                "exec sway --unsupported-gpu"
              else
                config.window-manager.name
            )
          }
          fi
        '';
      variables = {
        XDG_SESSION_TYPE = "wayland";
        __GL_GSYNC_ALLOWED = "1";
        __GL_VRR_ALLOWED = "0";
        QT_AUTO_SCREEN_SCALE_FACTOR = "1";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      };
    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;

      config = {
        common.default = [ "gtk" ];
        hyprland.default = [
          "gtk"
          "hyprland"
        ];
      };

      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal
        pkgs.xdg-desktop-portal-wlr
      ];
    };
  };
}
