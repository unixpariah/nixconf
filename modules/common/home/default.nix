_: {
  services = {
    syncthing = {
      enable = true;
      settings = {
        devices = {
          laptop.id = "EAEUDTW-MYUAJ2K-ICVZEU7-HEH6HW6-ORHR3WQ-KDD7ZJV-KAERKQT-LGDMFQJ";
          laptop-huawei.id = "6WHTLLC-K25CB25-E2DMCA3-3GJWP2S-EJA7RS5-TVITEIJ-IY3KZOJ-JSMBQQM";
          server-0.id = "NEPJ3NR-4JAUH6C-RXJ7HGP-TUHX4RM-WRVHGT5-MCVJUXM-Y5JOFHN-5TLFMQX";
          agent-0.id = "6G46TLU-KUO43K7-RR7OX5Q-HFTNP5N-QIZWQS2-PUROY25-ZQZACKC-HIMCKAR";
          t851.id = "YP57GK4-TGH3N6K-S46QN4A-F5XV63N-OTO6S5E-CGPVU4N-TXPLLR5-FWNKDAE";
        };
        folders = {
          "~/Documents" = {
            path = "~/Documents";
            devices = [
              "laptop"
              "laptop-huawei"
              "t851"
            ];
          };
          "~/Pictures" = {
            path = "~/Pictures";
            devices = [
              "laptop"
              "laptop-huawei"
              "t851"
            ];
          };
          "~/Videos" = {
            path = "~/Videos";
            devices = [
              "laptop"
              "laptop-huawei"
              "t851"
            ];
          };
          "~/Music" = {
            path = "~/Music";
            devices = [
              "laptop"
              "laptop-huawei"
              "t851"
            ];
          };
        };
      };
    };
  };
}
