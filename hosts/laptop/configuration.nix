{
  pkgs,
  inputs,
  config,
  ...
}:
{
  imports = [
    ./disko.nix
    ./gpu.nix
    ./hardware-configuration.nix
  ];

  stylix = {
    enable = true;
    image = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/refs/heads/master/wallpapers/nixos-wallpaper-catppuccin-mocha.png";
      sha256 = "7e6285630da06006058cebf896bf089173ed65f135fbcf32290e2f8c471ac75b";
    };
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    polarity = "dark";
  };

  security.pam.services.swaylock = { };
  security.pam.services.hyprlock = { };

  virtualisation = {
    waydroid.enable = true;
    virt-manager.enable = true;
    distrobox = {
      enable = false;
      images = {
        archlinux = {
          enable = true;
        };
      };
    };
  };

  system = {
    fileSystem = "btrfs";
    bootloader = {
      variant = "lanzaboote";
      silent = true;
    };
    ydotool.enable = true;
    displayManager = {
      enable = true;
      variant = "greetd";
    };
    impermanence = {
      enable = true;
      persist = {
        directories = [
          "/var/log"
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
        ];
        files = [ ];
      };
    };
    gc = {
      enable = true;
      interval = 3;
    };
  };

  security = {
    yubikey = {
      enable = true;
      rootAuth = true;
      unplug = {
        enable = true;
        action = "${pkgs.hyprlock}/bin/hyprlock";
      };
    };
    root = {
      auth = {
        passwordless = true;
        rootPw = true;
      };
      timeout = 0;
    };
  };

  hardware = {
    power-management = {
      enable = true;
      thresh = {
        start = 40;
        stop = 80;
      };
    };
    audio.enable = true;
    bluetooth.enable = true;
  };

  network = {
    ssh.enable = true;
    wireless.enable = true;
  };

  zramSwap.enable = true;

  services.protonvpn = {
    enable = false;
    interface = {
      privateKeyFile = config.sops.secrets.wireguard-key.path;
      ip = "10.2.0.2/32";
    };
    endpoint = {
      publicKey = "dldo97jXTUvjEQqaAx3pHy4lKFSxcmZYDCGFvvDOIGQ=";
      ip = "149.34.244.179";
    };
  };

  environment = {
    variables.EDITOR = "nvim";
    systemPackages = with pkgs; [
      inputs.nixvim.packages.${system}.default
    ];
  };

  sops.secrets = {
    "ssh_keys/unixpariah" = {
      owner = "unixpariah";
      path = "/home/unixpariah/.ssh/id_ed25519";
    };
    "ssh_keys/unixpariah-yubikey" = {
      owner = "unixpariah";
      path = "/home/unixpariah/.ssh/id_yubikey";
    };
    wireguard-key = { };
  };

  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";
}
