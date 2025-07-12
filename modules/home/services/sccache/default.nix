{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.sccache;
in
{
  options.services.sccache = {
    enable = lib.mkEnableOption "sccache";
    package = lib.mkPackageOption pkgs "sccache" { };
  };

  config = lib.mkIf cfg.enable {
    home.file.".cargo/config.toml".text = ''
      [build]
      rustc-wrapper = "${cfg.package}/bin/sccache"
    '';

    systemd.user.services.sccache = {
      Unit = {
        Description = "sccache-dist server";
        Wants = [ "network-online.target" ];
        After = [ "network-online.target" ];
      };
      Service.ExecStart = "${cfg.package}/bin/sccache-dist server --config ${config.xdg.configHome}";
    };
  };
}
