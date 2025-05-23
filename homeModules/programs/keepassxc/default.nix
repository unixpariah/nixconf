{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.programs.keepassxc;
in
{
  options.programs.keepassxc = {
    database = {
      files = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "Files containing databases, unnecessary if impermanence disabled";
        default = [ ];
      };
      directories = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "Directories containing databases, unnecessary if impermanence disabled";
        default = [ ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [ keepassxc ];
      persist = {
        directories = [ ".config/keepassxc" ] ++ cfg.database.directories;
        inherit (cfg.database) files;
      };
    };
  };
}
