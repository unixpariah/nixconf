{
  pkgs,
  lib,
  config,
  systemUsers,
  hostname,
  inputs,
  ...
}:
{
  imports = [
    ./system
    ./hardware
    ./network
    ./security
    ./environment
    ../hosts/${hostname}/configuration.nix
    ../derivations
  ];

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  nixpkgs.overlays = [ inputs.nixpkgs-wayland.overlay ];

  programs = {
    fish.enable = true;
    zsh.enable = true;
    nano.enable = lib.mkDefault false;
  };

  users = {
    mutableUsers = false;
    users =
      {
        root = {
          isNormalUser = false;
          hashedPasswordFile = config.sops.secrets.password.path;
          extraGroups = [ "wheel" ];
        };
      }
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
    substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
      "https://nixpkgs-wayland.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    trusted-users = [ "@wheel" ];
    allowed-users = [ "@wheel" ];
  };

  environment = {
    systemPackages = with pkgs; [
      nvd
      nix-output-monitor
      just
    ];
  };

  specialisation = {
    Wayland.configuration = {
      environment = {
        etc."specialisation".text = "Wayland";
        session = "Wayland";
      };
    };
    X11.configuration = {
      environment = {
        etc."specialisation".text = "X11";
        session = "X11";
      };
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
    };
    script =
      lib.attrNames systemUsers
      |> lib.concatMapStrings (user: ''
        if [ ! -d "/persist/home/${user}/.cache/home-generations/result" ]; then
            HOME_MANAGER_BACKUP_EXT="bak" nix build "/var/lib/nixconf#homeConfigurations.${user}@${hostname}.config.home.activationPackage" --log-format internal-json --verbose --out-link /persist/home/${user}/.cache/home-generations/result
        fi

        HOME_MANAGER_BACKUP_EXT="bak" specialisation_path=$(cat /etc/specialisation > /dev/null 2>&1 && echo /result/specialisation/$(cat /etc/specialisation) || echo /result/)

        chown -R ${user}:users /home/${user}/.ssh
        sudo -u ${user} /persist/home/${user}/.cache/home-generations/$specialisation_path/activate
      '');
  };

  system.stateVersion = "24.11";
}
