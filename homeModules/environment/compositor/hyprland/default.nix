{
  pkgs,
  lib,
  config,
  system_type,
  inputs,
  ...
}:
{
  home.packages = lib.mkIf config.wayland.windowManager.hyprland.enable [
    (pkgs.writeShellScriptBin "click" ''
      cursorpos=$(hyprctl cursorpos)
      x=$(echo $cursorpos | cut -d "," -f 1)
      y=$(echo $cursorpos | cut -d "," -f 2)
      initial_cursorpos="$x $y"

      ydotool mousemove -a $(seto -f $'%x %y\\n') && ydotool click 0xC0 && ydotool mousemove -a $initial_cursorpos
    '')
  ];

  wayland.windowManager.hyprland = {
    enable = lib.mkDefault (system_type == "desktop");
    package = inputs.hyprland.packages.${pkgs.system}.default;
    plugins = [ pkgs.hyprlandPlugins.hyprscroller ];
    settings = {
      input = {
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";

        follow_mouse = "1";

        touchpad = {
          disable_while_typing = "false";
          natural_scroll = "no";
        };

      };

      general = {
        border_size = 1;
        layout = "scroller";
      };

      plugin.scroller = {
        column_default_width = "one";
        center_row_if_space_available = true;
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

      gestures.workspace_swipe = false;

      misc = {
        force_default_wallpaper = "0";
        disable_hyprland_logo = "true";
        vfr = "true";
      };

      "$mainMod" = "ALT";

      bind =
        [
          ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
          ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"

          "$mainMod SHIFT, C, killactive,"
          "$mainMod, F, togglefloating,"

          "$mainMod, H, focusmonitor, -1"
          "$mainMod, L, focusmonitor, +1"

          "$mainMod SHIFT, H, movewindow, mon:-1"
          "$mainMod SHIFT, L, movewindow, mon:+1"

          "$mainMod, N, movefocus, l"
          "$mainMod, M, movefocus, r"

          "$mainMod SHIFT, N, movewindow, l"
          "$mainMod SHIFT, M, movewindow, r"

          ", XF86AudioRaiseVolume, exec, pamixer -i 5"
          ", XF86AudioLowerVolume, exec, pamixer -d 5"

          "$mainMod, q, exec, uwsm stop"
        ]
        ++ (lib.optional config.programs.seto.enable ", Print, exec, ${pkgs.grim}/bin/grim -c -g \"$(seto -r)\" - | ${pkgs.swappy}/bin/swappy -f -")
        ++ (lib.optional config.programs.moxctl.enable "$mainMod, D, exec, mox notify focus")
        ++ (lib.optional config.programs.seto.enable "$mainMod, G, exec, click");

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };
}
