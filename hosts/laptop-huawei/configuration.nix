{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkgs:
    builtins.elem (lib.getName pkgs) [
      "nvidia-x11"
      "steam"
      "steam-unwrapped"
      "libfprint-2-tod1-goodix"
    ];

  sops.secrets = {
    k3s = { };
    tailscale = { };
    deploy-rs = {
      owner = "deploy-rs";
      group = "wheel";
      mode = "0440";
    };
    "wireless/SaltoraUp" = { };
    "wireless/Saltora" = { };
  };

  boot.supportedFilesystems = [ "nfs" ];
  services = {
    nfs.server = {
      enable = true;
      exports = ''
        /tank/k8s-volumes 192.168.1.0/24(rw,no_subtree_check,no_root_squash,fsid=0)
      '';
    };

    rpcbind.enable = true;
    fprintd.enable = true;
    fprintd.tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix;
    };
  };

  documentation.enable = true;

  system = {
    bootloader = {
      variant = "systemd-boot";
      silent = true;
    };
    fileSystem = "zfs";
    gc = {
      enable = true;
      interval = 3;
    };
  };

  hardware = {
    power-management.enable = true;
  };

  environment = {
    variables.EDITOR = "hx";
    systemPackages = with pkgs; [
      nfs-utils
      helix
      kubectl
      cosmic-icons
    ];
  };

  security = {
    yubikey = {
      enable = true;
      rootAuth = true;
      id = "31888351";
      unplug.enable = true;
    };
    root.timeout = 0;
  };

  stylix = {
    enable = true;
    theme = "gruvbox";
  };

  programs = {
    sway.enable = false;
    hyprland.enable = false;

    deploy-rs.sshKeyFile = config.sops.secrets.deploy-rs.path;
    nix-index.enable = true;
  };

  gaming = {
    steam.enable = true;
  };

  networking = {
    wireless.iwd = {
      enable = true;
      networks = {
        SaltoraUp.psk = config.sops.secrets."wireless/SaltoraUp".path;
        Saltora.psk = config.sops.secrets."wireless/Saltora".path;
      };
    };

    hostId = "6add04c2";
    firewall.allowedTCPPorts = [
      80
      443
      2049
      6443
      8443
      3000
      30080
    ];
  };

  services = {
    impermanence.enable = true;
    tailscale.authKeyFile = config.sops.secrets.tailscale.path;
    k3s = {
      enable = true;
      tokenFile = config.sops.secrets.k3s.path;
      clusterInit = true;
      extraFlags = [
        "--disable traefik"
        "--disable servicelb"
        "--write-kubeconfig-mode \"0644\""
        "--disable local-storage"
        "--kube-controller-manager-arg bind-address=0.0.0.0"
        "--kube-proxy-arg metrics-bind-address=0.0.0.0"
        "--kube-scheduler-arg bind-address=0.0.0.0"
        "--etcd-expose-metrics true"
        "--kubelet-arg containerd=/run/k3s/containerd/containerd.sock"
      ];
    };
  };

  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";
}
