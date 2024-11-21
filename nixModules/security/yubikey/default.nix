{
  lib,
  config,
  pkgs,
  ...
}:
let
  root = (if config.impermanence.enable then "/persist/system/root" else "/root");
in
{
  options.yubikey = {
    enable = lib.mkEnableOption "yubikey";
    rootAuth = lib.mkEnableOption "root authentication";
  };

  config = lib.mkIf config.yubikey.enable {
    impermanence.persist.directories = lib.mkIf config.yubikey.rootAuth [ "/root/.config/Yubico" ];

    sops.secrets = lib.mkIf config.yubikey.rootAuth {
      "yubico/u2f_keys" = {
        path = "${root}/.config/Yubico/u2f_keys";
      };
    };

    environment.systemPackages = with pkgs; [
      yubioath-flutter
      yubikey-manager
      pam_u2f
    ];

    services = {
      pcscd.enable = true;
      udev.packages = with pkgs; [ yubikey-personalization ];
      yubikey-agent.enable = true;
    };

    security.pam = {
      sshAgentAuth.enable = true;
      u2f = lib.mkIf config.yubikey.rootAuth {
        enable = true;
        settings = {
          cue = true;
          authFile = "/root/.config/Yubico/u2f_keys";
        };
      };
      services = {
        login.u2fAuth = true;
        sudo = {
          rules.auth.rssh = {
            order = config.rules.auth.ssh_agent_auth.order - 1;
            control = "sufficient";
            modulePath = "${pkgs.pam_rssh}/lib/libpam_rssh.so";
            settings.authorized_keys_command = pkgs.writeShellScript "get-authorized-keys" "cat ~/etc/ssh/authorized_keys.d/$1";
          };
          u2fAuth = true;
          sshAgentAuth = true;
        };
      };
    };
  };
}
