{
  lib,
  config,
  pkgs,
  profile,
  ...
}:
{
  imports = [
    ./hyprland
    ./sway
    ./niri
  ];

  config = lib.mkIf (profile == "desktop") {
    environment = {
      loginShellInit = lib.mkIf (!config.system.displayManager.enable) ''
        if ${pkgs.uwsm}/bin/uwsm check may-start && ${pkgs.uwsm}/bin/uwsm select; then
            exec ${pkgs.uwsm}/bin/uwsm start default
        fi
      '';
      variables = {
        __GL_GSYNC_ALLOWED = "1";
        __GL_VRR_ALLOWED = "0";
        QT_AUTO_SCREEN_SCALE_FACTOR = "1";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      };
    };

    xdg = {
      mime.defaultApplications = {
        "inode/directory" = "cosmic-files.desktop";
      };
      terminal-exec.enable = true;
      portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        wlr = { inherit (config.programs.sway) enable; };

        config = {
          niri = {
            default = [
              "gnome"
              "gtk"
            ];
            "org.freedesktop.impl.portal.Access" = [ "gtk" ];
            "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
            "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
          };
          Hyprland = {
            default = [
              "hyprland"
              "gtk"
            ];
          };
        };
      };
    };

    programs = {
      xwayland.enable = true;
      uwsm = {
        enable = true;
        waylandCompositors = {
          Hyprland = lib.mkIf config.programs.hyprland.enable {
            prettyName = "Hyprland";
            comment = "Compositor managed by UWSM";
            binPath = "/run/current-system/sw/bin/Hyprland";
          };
          sway = lib.mkIf config.programs.sway.enable {
            prettyName = "Sway";
            comment = "Compositor managed by UWSM";
            binPath = "/run/current-system/sw/bin/sway";
          };
          niri = lib.mkIf config.programs.niri.enable {
            prettyName = "Niri";
            comment = "Compositor managed by UWSM";
            binPath = "/run/current-system/sw/bin/niri-session";
          };
          gamescope = lib.mkIf config.gaming.gamescope.enable {
            prettyName = "Gamescope";
            comment = "Compositor managed by UWSM";
            binPath = "/run/current-system/sw/bin/gamescope-session-uwsm";
          };
        };
      };
    };
  };
}
