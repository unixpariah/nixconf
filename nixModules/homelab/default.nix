{ config, lib, ... }:
let
  cfg = config.homelab;
in
{
  options.homelab = {
    enable = lib.mkEnableOption "homelab";
  };

  config = lib.mkIf cfg.enable {

  };
}
