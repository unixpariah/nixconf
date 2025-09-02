{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.services.impermanence;
  inherit (lib) types;
in
{
  imports = [ inputs.impermanence.homeManagerModules.impermanence ];

  options = {
    services.impermanence.enable = lib.mkEnableOption "impermanence";
    home.persist = {
      directories = lib.mkOption {
        type = types.listOf types.anything;
        default = [ ];
      };
      files = lib.mkOption {
        type = types.listOf types.anything;
        default = [ ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.persistence."/persist${config.home.homeDirectory}" = {
      directories = [
        ".local/state/nix/profiles"
        ".cache/nix-index"
      ]
      ++ config.home.persist.directories;
      inherit (config.home.persist) files;
      allowOther = true;
    };
  };
}
