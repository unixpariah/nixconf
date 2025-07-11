# Global configuration for yubikey-agent.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.yubikey-agent;
in
{
  options = {
    services.yubikey-agent = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to start yubikey-agent when you log in.  Also sets
          SSH_AUTH_SOCK to point at yubikey-agent.

          Note that yubikey-agent will use whatever pinentry is
          specified in programs.gnupg.agent.pinentryPackage.
        '';
      };

      package = lib.mkPackageOption pkgs "yubikey-agent" { };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    systemd.packages = [ cfg.package ];

    # This overrides the systemd user unit shipped with the
    # yubikey-agent package
    #systemd.user.services.yubikey-agent =
    #  lib.mkIf (config.programs.gnupg.agent.pinentryPackage != null)
    #    {
    #      path = [ config.programs.gnupg.agent.pinentryPackage ];
    #      wantedBy = [ "default.target" ];
    #    };

    # Yubikey-agent expects pcsd to be running in order to function.
    services.pcscd.enable = true;

    #environment.extraInit = ''
    #  if [ -z "$SSH_AUTH_SOCK" -a -n "$XDG_RUNTIME_DIR" ]; then
    #    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/yubikey-agent/yubikey-agent.sock"
    #  fi
    #'';
  };
}
