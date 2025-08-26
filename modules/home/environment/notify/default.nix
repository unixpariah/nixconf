{
  config,
  lib,
  profile,
  platform,
  pkgs,
  ...
}:
let
  cfg = config.environment.notify;
  inherit (lib) types;
in
{
  options.environment.notify = {
    enable = lib.mkOption {
      type = types.bool;
      default = profile == "desktop";
    };
    package = lib.mkOption {
      type = types.package;
      default = if platform == "non-nixos" then config.lib.nixGL.wrap pkgs.moxnotify else pkgs.moxnotify;
    };
  };

  config = {
    home.persist.directories = [ ".local/share/moxnotify" ];
    services.moxnotify = {
      inherit (cfg) enable;
      inherit (cfg) package;
      settings = {
        general = {
          margin.top = 50;
          history.size = 10000;
          default_sound_file = "/run/current-system/sw/share/sounds/freedesktop/stereo/message.oga";
          theme = "Cosmic";
        };

        styles = [ ];

        keymaps = [
          {
            mode = "n";
            keys = "d";
            action = "dismiss_notification";
          }
          {
            mode = "n";
            keys = "ge";
            action = "last_notification";
          }
          {
            mode = "n";
            keys = "<C-g>";
            action = "last_notification";
          }
          {
            mode = "n";
            keys = "gw";
            action = "hint_mode";
          }
          {
            mode = "n";
            keys = "f";
            action = "noop";
          }
        ];
      };
    };

    #nix.settings = {
    #  substituters = [ "https://moxnotify.cachix.org" ];
    #  trusted-substituters = [ "https://moxnotify.cachix.org" ];
    #  trusted-public-keys = [ "moxnotify.cachix.org-1:YVtjC6ZS1as13P1zHHVi/p3bx93tGsP2mUjzEn3T4X4=" ];
    #};
  };
}
