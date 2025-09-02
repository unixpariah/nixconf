{
  pkgs,
  lib,
  inputs,
  config,
  platform,
  ...
}:
{
  imports = [
    ./nix
    ./nixpkgs
    ./environment
    ./programs
    ./security
    ./networking
    ./services
    ./specialisation.nix
    ../theme
    inputs.mox-flake.homeManagerModules.moxidle
    inputs.mox-flake.homeManagerModules.moxnotify
    inputs.mox-flake.homeManagerModules.moxctl
    inputs.mox-flake.homeManagerModules.moxpaper
  ];

  xdg.configFile."environment.d/envvars.conf" = lib.mkIf (platform == "non-nixos") {
    text = ''
      PATH="${config.home.homeDirectory}/.nix-profile/bin:$PATH";
    '';
  };

  nixpkgs.overlays = import ../overlays inputs config ++ import ../lib config;

  home = {
    persist.directories = [ ".local/state/syncthing" ];
    packages = [
      (pkgs.writeShellScriptBin "nb" ''
        command "$@" > /dev/null 2>&1 &
        disown
      '')
    ];
    stateVersion = "25.11";
  };
}
