{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  sops.secrets = {
    tailscale = { };
  };

  services = {
    tailscale.authKeyFile = config.sops.secrets.tailscale.path;
  };

  system = {
    bootloader = {
      variant = "grub";
      legacy = true;
    };
    fileSystem = "btrfs";
  };

  networking = {
    wireless.iwd.enable = true;
    firewall.allowedTCPPorts = [
      80
      443
      6443
    ];
  };

  environment = {
    variables.EDITOR = "hx";
    systemPackages = with pkgs; [ helix ];
  };

  programs = {
    starship.enable = true;
    zoxide.enable = true;
    direnv.enable = true;
  };

  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";
}
