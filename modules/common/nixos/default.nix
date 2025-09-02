{ pkgs, config, ... }:
{
  imports = [ ./ssh.nix ];

  sops.secrets = {
    tailscale.sopsFile = ./secrets/secrets.yaml;

    "wireless/Saltora".sopsFile = ./secrets/secrets.yaml;
    "wireless/T-Mobile_5G_HomeOffice_2.4GHz".sopsFile = ./secrets/secrets.yaml;
    "wireless/T-Mobile_5G_HomeOffice_2.4GH_EXT".sopsFile = ./secrets/secrets.yaml;
    "wireless/T-Mobile_5G_HomeOffice_5GHz".sopsFile = ./secrets/secrets.yaml;
    "wireless/T-Mobile_5G_HomeOffice_5GHz_EXT".sopsFile = ./secrets/secrets.yaml;
    "wireless/Internet_Domowy_5G_660ECA".sopsFile = ./secrets/secrets.yaml;
    "wireless/Internet_Domowy_660ECA".sopsFile = ./secrets/secrets.yaml;
  };

  services.tailscale.authKeyFile = config.sops.secrets.tailscale.path;

  networking = {
    nameservers = [
      "9.9.9.9"
    ];

    wireless.iwd = {
      networks = {
        Saltora.psk = config.sops.secrets."wireless/Saltora".path;
        "=542d4d6f62696c655f35475f486f6d654f66666963655f322e3447487a".psk =
          config.sops.secrets."wireless/T-Mobile_5G_HomeOffice_2.4GHz".path;
        "=542d4d6f62696c655f35475f486f6d654f66666963655f322e3447485f455854".psk =
          config.sops.secrets."wireless/T-Mobile_5G_HomeOffice_2.4GH_EXT".path;
        T-Mobile_5G_HomeOffice_5GHz.psk = config.sops.secrets."wireless/T-Mobile_5G_HomeOffice_5GHz".path;
        T-Mobile_5G_HomeOffice_5GHz_EXT.psk =
          config.sops.secrets."wireless/T-Mobile_5G_HomeOffice_5GHz_EXT".path;
        Internet_Domowy_660ECA.psk = config.sops.secrets."wireless/Internet_Domowy_660ECA".path;
        Internet_Domowy_5G_660ECA.psk = config.sops.secrets."wireless/Internet_Domowy_5G_660ECA".path;
      };
    };
  };

  environment = {
    variables.EDITOR = "hx";
    systemPackages = [ pkgs.helix ];
  };
}
