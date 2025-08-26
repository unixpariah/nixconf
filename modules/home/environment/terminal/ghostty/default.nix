{
  config,
  platform,
  pkgs,
  ...
}:
let
  cfg = config.environment.terminal;
in
{
  programs.ghostty = {
    enable = cfg.enable && cfg.program == "ghostty";
    package = if platform == "non-nixos" then config.lib.nixGL.wrap pkgs.ghostty else pkgs.ghostty;
    settings = {
      window-decoration = false;
      confirm-close-surface = false;
    };
  };
}
