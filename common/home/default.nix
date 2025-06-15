{ ... }:
{
  programs.atuin = {
    enable = true;
    settings = {
      auto_sync = true;
      sync_address = "http://atuin.your-domain.com";
    };
  };

  services.syncthing = {
    enable = true;
    settings = {
      devices = {
        laptop.id = "F265KCD-YJPGOI2-SZJT5TH-FNDPNGU-S7CZGD6-75VIYU4-KN4OPOP-TVGCCQM";
        laptop-huawei.id = "BEPHLDU-U4RLH7V-7YLQOBN-L2IX2B2-OBJV5SP-MZMEHLF-PI7VFUQ-F2X5VQO";
        server-0.id = "NEPJ3NR-4JAUH6C-RXJ7HGP-TUHX4RM-WRVHGT5-MCVJUXM-Y5JOFHN-5TLFMQX";
        agent-0.id = "6G46TLU-KUO43K7-RR7OX5Q-HFTNP5N-QIZWQS2-PUROY25-ZQZACKC-HIMCKAR";
      };
      folders = {
        "/var/lib/nixconf" = {
          path = "/var/lib/nixconf";
          devices = [
            "laptop"
            "laptop-huawei"
            "agent-0"
            "server-0"
          ];
        };
        "~/Documents" = {
          path = "~/Documents";
          devices = [
            "laptop"
            "laptop-huawei"
          ];
        };
        "~/Pictures" = {
          path = "~/Pictures";
          devices = [
            "laptop"
            "laptop-huawei"
          ];
        };
        "~/Videos" = {
          path = "~/Videos";
          devices = [
            "laptop"
            "laptop-huawei"
          ];
        };
        "~/Music" = {
          path = "~/Music";
          devices = [
            "laptop"
            "laptop-huawei"
          ];
        };
        "~/workspace" = {
          path = "~/workspace";
          devices = [
            "laptop"
            "laptop-huawei"
          ];
        };
      };
    };
  };
}
