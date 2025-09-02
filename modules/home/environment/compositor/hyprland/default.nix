{
  pkgs,
  lib,
  config,
  platform,
  ...
}:
let
  cfg = config.programs.hyprland;
  inherit (lib) types;
in
{
  options.programs.hyprland = {
    enable = lib.mkEnableOption "hyprland";
    package = lib.mkOption {
      type = types.package;
      default = if platform == "non-nixos" then (config.lib.nixGL.wrap pkgs.hyprland) else pkgs.hyprland;
    };
  };

  config = {
    wayland.windowManager.hyprland = {
      inherit (cfg) enable;
      inherit (cfg) package;

      plugins = [ pkgs.hyprscroller ];

      settings = {
        layerrule = [ "noanim, moxnotify" ];

        input = {
          kb_layout = "us";
          kb_variant = "";
          kb_model = "";
          kb_options = "";
          kb_rules = "";

          follow_mouse = "1";

          touchpad = {
            disable_while_typing = false;
            natural_scroll = "no";
          };
        };

        ecosystem.no_update_news = true;

        general = {
          border_size = 1;
          layout = "scroller";
        };

        plugin.scroller = {
          column_default_width = "one";
          center_row_if_space_available = true;
          column_widths = "onethird onehalf twothirds one";
          window_heights = "onethird onehalf twothirds one";
        };

        decoration = {
          rounding = 16;

          blur.enabled = false;
        };

        debug.disable_logs = false;

        animations = {
          enabled = true;

          bezier = [
            "overshot, 0.05, 0.9, 0.1, 1.05"
            "smoothOut, 0.36, 0, 0.66, -0.56"
            "smoothIn, 0.25, 1, 0.5, 1"
          ];

          animation = [
            "windows, 1, 5, overshot, slide"
            "windowsOut, 1, 4, smoothOut, slide"
            "windowsMove, 1, 4, default"
            "border, 1, 10, default"
            "fadeDim, 1, 10, smoothIn"
            "workspaces, 1, 6, default"
          ];
        };

        misc = {
          force_default_wallpaper = "0";
          vfr = true;
        };

        "$mainMod" = "ALT"; # Mod key

        bind = [
          ", XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl set +5%"
          ", XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 5%-"

          "$mainMod SHIFT, C, killactive,"
          "$mainMod, F, togglefloating,"

          "$mainMod, H, scroller:movefocus, l"
          "$mainMod, L, scroller:movefocus, r"
          "$mainMod, J, scroller:movefocus, d"
          "$mainMod, K, scroller:movefocus, u"

          "$mainMod SHIFT, H, scroller:movewindow, l"
          "$mainMod SHIFT, L, scroller:movewindow, r"

          "$mainMod SHIFT, K, scroller:movewindow, mon:u"
          "$mainMod SHIFT, J, scroller:movewindow, mon:d"
          "$mainMod SHIFT, N, scroller:movewindow, mon:l"
          "$mainMod SHIFT, M, scroller:movewindow, mon:r"

          "$mainMod SHIFT, N, scroller:movefocus, mon:l"
          "$mainMod SHIFT, M, scroller:movefocus, mon:r"

          "$mainMod, R, scroller:cyclewidth, next"

          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"

          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "$mainMod SHIFT, 0, movetoworkspace, 10"

          "$mainMod, D, exec, ${pkgs.moxctl}/bin/mox notify focus"

          ", XF86AudioRaiseVolume, exec, ${pkgs.pamixer}/bin/pamixer -i 5"
          ", XF86AudioLowerVolume, exec, ${pkgs.pamixer}/bin/pamixer -d 5"

          "$mainMod, q, exec, ${pkgs.uwsm}/bin/uwsm stop"
        ];

        bindm = [
          # Move/resize windows with mainMod + LMB/RMB and dragging
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];
      };
    };
  };
}
