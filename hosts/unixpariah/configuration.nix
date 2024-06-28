{
  inputs,
  pkgs,
  lib,
  ...
}: let
  config = {
    colorscheme = "catppuccin"; # Options: catppuccin
    font = "JetBrainsMono Nerd Font";
    terminal = "foot"; # Options: kitty, foot
    editor = "nvim"; # Options: nvim
    shell = "zsh"; # Options: fish, zsh | Default: bash
    browser = "qutebrowser"; # Options: firefox, qutebrowser, chromium
    grub = true; # false = systemd-boot, true = grub
    zoxide = true;
    nh = true;
    virtualization = true;
    audio = true;
    wireless = true;
    power = true;
    tmux = true;
    username = "unixpariah";
    hostname = "laptop";
    password = "$6$Kj8QuIvw.6mcNf4W$3XWGupFAdvZ/upIFcwR4ZWwdyLt5dfAT4PREIVJ8kZ42Mh/BLLxPSzhMSfQdN2mfPhGfZg69nS4atiG1vEsuS1";
  };
in {
  imports = [
    (import ../../nixModules/default.nix {inherit config inputs pkgs lib;})
    # ./disko.nix
    ./gpu.nix
    ./hardware-configuration.nix
  ];

  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.shellAliases = {
    cat = "bat";
    ls = "lsd";
  };

  environment.systemPackages = with pkgs; [
    ydotool
    zathura
    libreoffice
    lazygit
    discord
    bat
    lsd
    brightnessctl
    grim
    unzip
    btop
    vaapi-intel-hybrid
    spotify
    steam
    gimp
    nix-prefetch-git
  ];

  fonts.packages = with pkgs; [
    jetbrains-mono
    font-awesome
    nerdfonts
  ];

  system.stateVersion = "23.11";
}
