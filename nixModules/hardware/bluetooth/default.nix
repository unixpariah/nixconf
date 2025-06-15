{
  config,
  lib,
  system_type,
  ...
}:
let
  cfg = config.hardware.bluetooth;
in
{
  hardware.bluetooth = {
    enable = lib.mkDefault (system_type == "desktop");
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };

  services.blueman.enable = cfg.enable;

  environment.persist.directories = lib.mkIf cfg.enable [ "/var/lib/bluetooth" ];
}
