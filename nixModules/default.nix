{
  pkgs,
  lib,
  config,
  systemUsers,
  hostname,
  ...
}:
{
  imports = [
    ./system
    ./hardware
    ./network
    ./security
    ./environments
    ../hosts/${hostname}/configuration.nix
  ];

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  # Enables all required shells
  programs =
    (builtins.attrValues systemUsers)
    |> builtins.foldl' (
      acc: user:
      acc
      // {
        ${user.shell}.enable = true;
      }
    ) { nano.enable = lib.mkDefault false; };

  users = {
    mutableUsers = false;
    users =
      { }
      // lib.mapAttrs (name: value: {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.${name}.path;
        extraGroups = lib.mkIf value.root.enable [ "wheel" ];
        shell = pkgs.${value.shell};
      }) systemUsers;
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];
    auto-optimise-store = true;
    substituters = [ "https://nix-community.cachix.org" ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    trusted-users = [
      "root"
      "@wheel"
    ];
  };

  specialisation = {
    Hyprland.configuration = {
      window-manager = {
        enable = true;
        name = "Hyprland";
        backend = "Wayland";
      };
      environment.etc."specialisation".text = "Hyprland";
    };
    sway.configuration = {
      window-manager = {
        enable = true;
        name = "sway";
        backend = "Wayland";
      };
      environment.etc."specialisation".text = "sway";
    };
    niri.configuration = {
      window-manager = {
        enable = true;
        name = "niri";
        backend = "Wayland";
      };
      environment.etc."specialisation".text = "niri";
    };
    i3.configuration = {
      window-manager = {
        enable = true;
        name = "i3";
        backend = "X11";
      };
      environment.etc."specialisation".text = "i3";
    };
  };

  systemd.services.activate-home-manager = lib.mkIf config.system.impermanence.enable {
    enable = true;
    description = "Activate home manager";
    wantedBy = [ "default.target" ];
    requiredBy = [ "systemd-user-sessions.service" ];
    before = [ "systemd-user-sessions.service" ];
    serviceConfig = {
      Type = "oneshot";
    };
    environment = {
      PATH = lib.mkForce "${pkgs.nix}/bin:${pkgs.git}/bin:${pkgs.home-manager}:${pkgs.sudo}/bin:${pkgs.coreutils}/bin:$PATH";
      HOME_MANAGER_BACKUP_EXT = "bak";
    };
    script = lib.concatMapStrings (user: ''
      if [ ! -d "/persist/home/${user}/.cache/home-generations/result" ]; then
          nix build "/var/lib/nixconf#homeConfigurations.${user}@${hostname}.config.home.activationPackage" --log-format internal-json --verbose --out-link /persist/home/${user}/.cache/home-generations/result
      fi

      specialisation_path=$(cat /etc/specialisation > /dev/null 2>&1 && echo /result/specialisation/$(cat /etc/specialisation) || echo /result/)

      chown -R ${user}:users /home/${user}/.ssh
      sudo -u ${user} /persist/home/${user}/.cache/home-generations/$specialisation_path/activate
    '') (lib.attrNames systemUsers);
  };

  system.stateVersion = "24.11";
}
