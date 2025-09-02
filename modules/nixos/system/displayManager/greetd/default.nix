{ lib, config, ... }:
let
  cfg = config.system.displayManager;
in
{
  imports = [ ./tuigreet ];

  config = lib.mkIf cfg.enable {
    services.greetd.enable = true;

    programs.tuigreet = {
      enable = true;
      time = {
        enable = true;
        format = "%d.%m.%Y";
      };
      greeting = {
        enable = true;
        text = "Kill yourself";
      };
      asterisks.enable = true;
      user = {
        menu.enable = true;
        remember = true;
        rememberSession = true;
      };
      power = {
        shutdown = "systemctl poweroff";
        reboot = "systemctl reboot";
      };
    };
  };
}
