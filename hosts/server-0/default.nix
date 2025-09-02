{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  sops.secrets = {
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

    "atuin/DB_PASSWORD" = { };
    "atuin/DB_URI" = { };

    YUBI = { };
  };

  system = {
    fileSystem = "zfs";
  };

  homelab = {
    enable = true;
    atuin = {
      enable = true;
      db = {
        username = "atuin";
        passwordFile = config.sops.secrets."atuin/DB_PASSWORD".path;
        uriFile = config.sops.secrets."atuin/DB_URI".path;
        resources = {
          requests = {
            cpu = "100m";
            memory = "100Mi";
          };
          limits = {
            cpu = "250m";
            memory = "600Mi";
          };
          storage = "300Mi";
        };
      };
    };
    pihole = {
      domain = "pihole.your-domain.com";
      dns = "192.168.30.1";
      passwordFile = config.sops.secrets."pihole-password/password".path;
      adlists = [ "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt" ];
      webLoadBalancerIP = "192.168.30.102";
      dnsLoadBalancerIP = "192.168.30.103";
    };
    vaultwarden = {
      enable = true;
      hostname = "vaultwarden.your-domain.com";
      storage = "512Mi";
      yubikey = {
        enable = true;
        keyFile = config.sops.secrets.YUBI.path;
      };
    };
    metallb.addresses = [ "192.168.30.100-192.168.30.150" ];
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

  services = {
    gc = {
      enable = true;
      interval = 3;
    };
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
    k3s = {
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
    interfaces.enp3s0.ipv4.addresses = [
      {
        address = "192.168.30.141";
        prefixLength = 24;
      }
    ];
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
