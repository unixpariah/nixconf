{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  sops.secrets = {
    tailscale = { };
    k3s = { };

    "grafana/username" = { };
    "grafana/password" = { };

    github-api = { };

    "pihole-password/password" = { };

    "immich-postgres-user/DB_USERNAME" = { };
    "immich-postgres-user/DB_DATABASE_NAME" = { };
    "immich-postgres-user/DB_PASSWORD" = { };
    "immich-postgres-user/username" = { };
    "immich-postgres-user/password" = { };

    "atuin/DB_USERNAME" = { };
    "atuin/DB_PASSWORD" = { };
    "atuin/DB_URI" = { };

    YUBI = { };
  };

  system = {
    bootloader.variant = "systemd-boot";
    fileSystem = "zfs";
    gc = {
      enable = true;
      interval = 3;
    };
  };

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  users.users.unixpariah.extraGroups = [ "podman" ];

  services = {
    #cloudflared = {
    #  enable = true;
    #  tunnels = {
    #    "00000000-0000-0000-0000-000000000000" = {
    #      credentialsFile = "/tmp/test";
    #      default = "http_status:404";
    #      ingress = {
    #        "*.your-domain.com" = {
    #          service = "http://localhost:80";
    #        };
    #      };
    #    };
    #  };
    #};
    impermanence.enable = true;
    tailscale.authKeyFile = config.sops.secrets.tailscale.path;
    k3s = {
      enable = true;
      tokenFile = config.sops.secrets.k3s.path;
      clusterInit = true;
      secrets = [
        {
          name = "grafana-admin-credentials";
          namespace = "monitoring";
          data = {
            admin-user = config.sops.secrets."grafana/username".path;
            admin-password = config.sops.secrets."grafana/password".path;
          };
        }
        {
          name = "github-api";
          namespace = "portfolio";
          data.github_api = config.sops.secrets.github-api.path;
        }
        {
          name = "pihole-password";
          namespace = "pihole-system";
          data.password = config.sops.secrets."pihole-password/password".path;
        }
        {
          name = "immich-postgres-user";
          namespace = "immich";
          data = {
            DB_USERNAME = config.sops.secrets."immich-postgres-user/DB_USERNAME".path;
            DB_DATABASE_NAME = config.sops.secrets."immich-postgres-user/DB_DATABASE_NAME".path;
            DB_PASSWORD = config.sops.secrets."immich-postgres-user/DB_PASSWORD".path;
            username = config.sops.secrets."immich-postgres-user/username".path;
            password = config.sops.secrets."immich-postgres-user/password".path;
          };
        }
        {
          name = "yubisecret";
          namespace = "vaultwarden";
          data.YUBI = config.sops.secrets.YUBI.path;
        }
        {
          name = "atuin-secrets";
          namespace = "atuin";
          data = {
            ATUIN_DB_USERNAME = config.sops.secrets."atuin/DB_USERNAME".path;
            ATUIN_DB_PASSWORD = config.sops.secrets."atuin/DB_PASSWORD".path;
            ATUIN_DB_URI = config.sops.secrets."atuin/DB_URI".path;
          };
        }
      ];
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

  networking = {
    hostId = "830a5f18";
    firewall.allowedTCPPorts = [
      6443
      2379
      2380
      8472
    ];
  };

  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";
}
