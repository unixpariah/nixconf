{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  userConfig = {
    username = "unixpariah";
    hostname = "laptop";
    colorscheme = "catppuccin";
    font = "JetBrainsMono Nerd Font";
    terminal = "foot";
    editor = "nvim";
    shell = "zsh";
    browser = "firefox";
    power = true;
  };
in {
  imports = [
    (import ../../nixModules/default.nix {inherit userConfig inputs pkgs lib config;})
    ./gpu.nix
    ./hardware-configuration.nix
  ];

  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    libreoffice
    lazygit
    discord
    brightnessctl
    grim
    unzip
    btop
    vaapi-intel-hybrid
    steam
    gimp
    spotify
  ];

  fonts.packages = with pkgs; [
    jetbrains-mono
    font-awesome
    nerdfonts
  ];

  system.stateVersion = "23.11";
}
