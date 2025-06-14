{
  config,
  lib,
  pkgs,
  systemUsers,
  ...
}:
let
  cfg = config.gaming.lutris;
in
{
  options.gaming.lutris = {
    enable = lib.mkEnableOption "Enable lutris";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.lutris;
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = [ (cfg.package.override { extraPkgs = pkgs: [ ]; }) ];
      persist.users.directories = [
        ".local/share/lutris"
        "Games/Lutris"
      ];
    };
  };
}
