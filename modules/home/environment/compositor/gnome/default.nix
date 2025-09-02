# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
# YES I KNOW GNOME IS A DESKTOP ENVIRONMENT AND NOT COMPOSITOR
# BUT I DIDNT WANT TO CREATE A SEPARATE SECTION AND THIS HAS
# GENERAL GNOME SETTINGS
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.programs.gnome;
in
with lib.hm.gvariant;
{
  options.programs.gnome.enable = lib.mkEnableOption "gnome";

  config = lib.mkIf cfg.enable {
    programs.gnome-shell = {
      enable = true;
      extensions = [
        #{ package = pkgs.gnomeExtensions.burn-my-windows; }
        { package = pkgs.gnomeExtensions.paperwm; }
      ];
    };

    ### EXTENSIONS ###
    dconf.settings = {
      "org/gnome/shell" = {
        disabled-extensions = [ ];
        enabled-extensions = [
          "user-theme@gnome-shell-extensions.gcampax.github.com"
          "ding@rastersoft.com"
          "ubuntu-dock@ubuntu.com"
          "tiling-assistant@ubuntu.com"
          "burn-my-windows@schneegans.github.com"
          "paperwm@paperwm.github.com"
        ];
        welcome-dialog-last-shown-version = "46.0";
      };

      "org/gnome/shell/extensions/paperwm" = {
        gesture-horizontal-fingers = 4;
        last-used-display-server = "Wayland";
        restore-attach-modal-dialogs = "true";
        restore-edge-tiling = "false";
        restore-keybinds = ''
          {"move-to-monitor-right":{"bind":"[\\"<Shift><Alt>m\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-to-workspace-left":{"bind":"[\\"<Alt>h\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-to-workspace-right":{"bind":"[\\"<Alt>l\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-monitor-up":{"bind":"[\\"<Shift><Alt>k\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"maximize":{"bind":"[\\"<Alt>f\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-monitor-down":{"bind":"[\\"<Shift><Alt>j\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-workspace-left":{"bind":"[\\"<Shift><Alt>h\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-workspace-right":{"bind":"[\\"<Shift><Alt>l\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-monitor-left":{"bind":"[\\"<Shift><Alt>n\\"]","schema_id":"org.gnome.desktop.wm.keybindings"}}
        '';
        restore-workspaces-only-on-primary = "true";
        show-workspace-indicator = false;
        window-gap = 18;
      };

      "org/gnome/shell/extensions/paperwm/keybindings" = {
        center = [ "<Alt>c" ];
        move-down = [ "" ];
        move-left = [ "<Shift><Alt>h" ];
        move-monitor-above = [ "<Shift><Alt>k" ];
        move-monitor-below = [ "<Shift><Alt>j" ];
        move-monitor-left = [ "<Shift><Alt>n" ];
        move-monitor-right = [ "<Shift><Alt>m" ];
        move-right = [ "<Shift><Alt>l" ];
        move-up = [ "" ];
        switch-down = [ "" ];
        switch-global-down = [ "<Alt>j" ];
        switch-global-up = [ "<Alt>k" ];
        switch-left = [ "<Alt>h" ];
        switch-monitor-above = [ "<Alt>Up" ];
        switch-monitor-below = [ "<Alt>Down" ];
        switch-monitor-left = [ "<Alt>n" ];
        switch-monitor-right = [ "<Alt>m" ];
        switch-right = [ "<Alt>l" ];
        switch-up = [ "" ];
        toggle-maximize-width = [ "<Alt>f" ];
      };

      "org/gnome/shell/extensions/dash-to-dock" = {
        dock-fixed = false;
        extend-height = false;
      };

      "org/gnome/shell/extensions/ding" = {
        check-x11wayland = true;
      };

      "org/gnome/shell/extensions/tiling-assistant" = {
        active-window-hint-color = "rgb(211,70,21)";
        last-version-installed = 46;
        tiling-popup-all-workspace = true;
      };

      "org/gnome/shell/extensions/user-theme" = {
        name = "Stylix";
      };
    };

    dconf.settings = {
      "org/gnome/TextEditor" = {
        style-scheme = "stylix";
      };

      "org/gnome/control-center" = {
        last-panel = "ubuntu";
        window-state = mkTuple [
          980
          640
          true
        ];
      };

      "org/gnome/desktop/app-folders" = {
        folder-children = [
          "Utilities"
          "YaST"
          "Pardus"
        ];
      };

      "org/gnome/desktop/app-folders/folders/Pardus" = {
        categories = [ "X-Pardus-Apps" ];
        name = "X-Pardus-Apps.directory";
        translate = true;
      };

      "org/gnome/desktop/app-folders/folders/Utilities" = {
        apps = [
          "gnome-abrt.desktop"
          "gnome-system-log.desktop"
          "nm-connection-editor.desktop"
          "org.gnome.baobab.desktop"
          "org.gnome.Connections.desktop"
          "org.gnome.DejaDup.desktop"
          "org.gnome.Dictionary.desktop"
          "org.gnome.DiskUtility.desktop"
          "org.gnome.Evince.desktop"
          "org.gnome.FileRoller.desktop"
          "org.gnome.fonts.desktop"
          "org.gnome.Loupe.desktop"
          "org.gnome.seahorse.Application.desktop"
          "org.gnome.tweaks.desktop"
          "org.gnome.Usage.desktop"
          "vinagre.desktop"
        ];
        categories = [ "X-GNOME-Utilities" ];
        name = "X-GNOME-Utilities.directory";
        translate = true;
      };

      "org/gnome/desktop/app-folders/folders/YaST" = {
        categories = [ "X-SuSE-YaST" ];
        name = "suse-yast.directory";
        translate = true;
      };

      "org/gnome/desktop/applications/terminal" = {
        exec = "${config.environment.terminal.program}";
        exec-arg = "";
      };

      "org/gnome/desktop/input-sources" = {
        sources = [
          (mkTuple [
            "xkb"
            "us"
          ])
        ];
        xkb-options = [ ];
      };

      "org/gnome/desktop/interface" = {
        enable-hot-corners = true;
      };

      "org/gnome/desktop/notifications" = {
        application-children = [ "snapd-desktop-integration-snapd-desktop-integration" ];
      };

      "org/gnome/desktop/notifications/application/snapd-desktop-integration-snapd-desktop-integration" =
        {
          application-id = "snapd-desktop-integration_snapd-desktop-integration.desktop";
        };

      "org/gnome/desktop/search-providers" = {
        sort-order = [
          "org.gnome.Contacts.desktop"
          "org.gnome.Documents.desktop"
          "org.gnome.Nautilus.desktop"
        ];
      };

      "org/gnome/desktop/wm/keybindings" = {
        close = [ "<Shift><Alt>c" ];
        maximize = [ "<Alt>f" ];
        move-to-monitor-down = [ "<Shift><Alt>j" ];
        move-to-monitor-left = [ "<Shift><Alt>n" ];
        move-to-monitor-right = [ "<Shift><Alt>m" ];
        move-to-monitor-up = [ "<Shift><Alt>k" ];
        move-to-workspace-left = [ "<Shift><Alt>h" ];
        move-to-workspace-right = [ "<Shift><Alt>l" ];
        switch-to-workspace-left = [ "<Alt>h" ];
        switch-to-workspace-right = [ "<Alt>l" ];
      };

      "org/gnome/evolution-data-server" = {
        migrated = true;
      };

      "org/gnome/mutter" = {
        edge-tiling = false;
      };

      "org/gnome/mutter/keybindings" = {
        toggle-tiled-left = [ ];
        toggle-tiled-right = [ ];
      };

      "org/gnome/nautilus/preferences" = {
        migrated-gtk-settings = true;
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        search = [ "<Alt>s" ];
        terminal = [ "<Shift><Alt>Return" ];
      };

      "org/gnome/settings-daemon/plugins/power" = {
        sleep-inactive-ac-timeout = 3600;
        sleep-inactive-ac-type = "nothing";
      };

      "org/gnome/shell/world-clocks" = {
        locations = [ ];
      };

      "org/gtk/gtk4/settings/file-chooser" = {
        show-hidden = false;
        sort-directories-first = true;
      };
    };
  };
}
