{
  config,
  lib,
  profile,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.environment.idle;
  locker = "${pkgs.hyprlock}/bin/hyprlock";
in
{
  imports = [ inputs.moxidle.homeManagerModules.default ];

  options.environment.idle = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = profile == "desktop";
    };
  };

  config = {
    services.moxidle = {
      inherit (cfg) enable;
      settings = {
        general = {
          lock_cmd = "pidof ${locker} || ${locker}";
          unlock_cmd = "pkill -USR1 hyprlock";
          ignore_dbus_inhibit = false;
          ignore_systemd_inhibit = false;
          ignore_audio_inhibit = false;
        };
        listeners = [
          {
            conditions = [ { usb_unplugged = "1050:0407"; } ];
            timeout = 5;
            on_timeout = "${pkgs.libnotify}/bin/notify-send aha mhm";
          }
          {
            conditions = [
              "on_battery"
              { battery_level = "critical"; }
              { battery_state = "discharging"; }
              { usb_unplugged = "1050:0407"; }
            ];
            timeout = 300;
            on_timeout = "${pkgs.systemd}/bin/systemctl suspend";
          }
          {
            conditions = [
              "on_ac"
              { usb_unplugged = "1050:0407"; }
            ];
            timeout = 300;
            on_timeout = "${pkgs.systemd}/bin/loginctl lock-session";
          }
          {
            conditions = [
              "on_ac"
              { usb_unplugged = "1050:0407"; }
            ];
            timeout = 900;
            on_timeout = "${pkgs.systemd}/bin/systemctl suspend";
          }
        ];
      };
    };

    nix.settings = {
      substituters = [ "https://moxidle.cachix.org" ];
      trusted-substituters = [ "https://moxidle.cachix.org" ];
      trusted-public-keys = [ "moxidle.cachix.org-1:ck2KY0PlOsrgMUBfJaYVmcDbyHT2cK6KSvLP09amGUU=" ];
    };
  };
}
