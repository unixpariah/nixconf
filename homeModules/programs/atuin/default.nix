{ lib, config, ... }:
let
  cfg = config.programs.atuin;
in
{
  programs.atuin.daemon.enable = cfg.enable;
}
