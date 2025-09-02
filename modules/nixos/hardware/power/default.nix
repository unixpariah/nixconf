{ config, lib, ... }:
let
  cfg = config.hardware.power-management;
in
{
  options.hardware.power-management = {
    enable = lib.mkEnableOption "Enable power management";
  };

  config = lib.mkIf cfg.enable {
    systemd.services.powersave = {
      enable = true;

      description = "Apply power saving tweaks";
      wantedBy = [ "multi-user.target" ];

      script = ''
        echo 1500 > /proc/sys/vm/dirty_writeback_centisecs
        echo 1 > /sys/module/snd_hda_intel/parameters/power_save
        echo 0 > /proc/sys/kernel/nmi_watchdog

        for i in /sys/bus/pci/devices/*; do
          echo auto > "$i/power/control"
        done
      '';
    };

    services = {
      upower.enable = true;
      tlp = {
        enable =
          let
            inherit (config.services.desktopManager) gnome cosmic plasma6;
          in
          !gnome.enable && !cosmic.enable && !plasma6.enable;
        settings = {
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

          CPU_MIN_PERF_ON_AC = 0;
          CPU_MAX_PERF_ON_AC = 100;
          CPU_MIN_PERF_ON_BAT = 0;
          CPU_MAX_PERF_ON_BAT = 20;

          START_CHARGE_THRESH_BAT0 = 40;
          STOP_CHARGE_THRESH_BAT0 = 80;
        };
      };
      thermald.enable = true;
    };

    powerManagement.enable = true;
  };
}
