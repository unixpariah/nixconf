{
  config,
  lib,
  pkgs,
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
    home = {
      persist.directories = [
        ".local/share/lutris"
        "Games/Lutris"
      ];
    };
  };
}
