{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.gaming.steam;
in
{
  options.gaming.steam.enable = lib.mkEnableOption "Enable minecraft";

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        (writeShellScriptBin "steamos-session-select" ''
          steam -shutdown
        '')
      ];
      persist.directories = [
        {
          directory = ".steam";
          method = "symlink";
        }
        {
          directory = ".local/share/Steam";
          method = "symlink";
        }
        "Games/Steam"
      ];
    };
  };
}
