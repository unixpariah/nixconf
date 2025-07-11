{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.security.yubikey;
in
{
  options.security.yubikey = {
    enable = lib.mkEnableOption "yubikey";
    rootAuth = lib.mkEnableOption "root authentication";
    id = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.str;
    };
    actions = {
      unplug = {
        enable = lib.mkEnableOption "Action when unplugging";
        action = lib.mkOption {
          type = lib.types.str;
          default = "${pkgs.systemd}/bin/loginctl lock-sessions";
        };
      };
      plug = {
        enable = lib.mkEnableOption "Action when plugging in";
        action = lib.mkOption {
          type = lib.types.str;
          default = "${pkgs.systemd}/bin/loginctl unlock-sessions";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      udev.extraRules = lib.mkIf (cfg.actions.unplug.enable || cfg.actions.plug.enable) ''
        ${lib.optionalString cfg.actions.unplug.enable ''
          ACTION=="remove",\
          ENV{SUBSYSTEM}=="usb",\
          ENV{PRODUCT}=="1050/407/571",\
          RUN+="${cfg.actions.unplug.action}"
        ''}

        ${lib.optionalString cfg.actions.plug.enable ''
          ACTION=="add",\
          ENV{SUBSYSTEM}=="usb",\
          ENV{PRODUCT}=="1050/407/571",\
          ATTR{serial}=="31888351",\
          RUN+="${cfg.actions.plug.action}"
        ''}
      '';

      yubikey-agent.enable = true;
    };

    environment = {
      systemPackages = builtins.attrValues { inherit (pkgs) yubioath-flutter yubikey-manager pam_u2f; };

      etc = {
        "pam.d/sudo".text = ''
          #%PAM-1.0

          # Set up user limits from /etc/security/limits.conf.
          session    required   pam_limits.so

          session    required   pam_env.so readenv=1 user_readenv=0
          session    required   pam_env.so readenv=1 envfile=/etc/default/locale user_readenv=0
          auth       sufficient pam_u2f.so

          @include common-u2f
          @include common-auth
          @include common-account
          @include common-session-noninteractive
        '';
        "pam.d/common-u2f".text = ''
          auth sufficient pam_u2f.so authfile=/etc/u2f_mappings cue
        '';
        "pam.d/pamu2f".text = ''
          auth sufficient pam_u2f.so debug
        '';
      };
    };
  };
}
