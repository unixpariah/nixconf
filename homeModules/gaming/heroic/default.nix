{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.gaming.heroic;
in
{
  options.gaming.heroic = {
    enable = lib.mkEnableOption "Enable heroic launcher";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.heroic;
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ cfg.package ];
      persist.directories = [
        ".config/heroic"
        "Games/Heroic"
      ];
    };
  };
}
