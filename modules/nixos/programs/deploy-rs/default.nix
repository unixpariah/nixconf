{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.programs.deploy-rs;
  inherit (lib) types;
in
{
  options.programs.deploy-rs = {
    enable = lib.mkOption {
      type = types.bool;
      default = true;
    };
    #package = lib.mkPackageOption pkgs "deploy-rs" { }; TODO
    sshKeyFile = lib.mkOption {
      type = types.nullOr types.path;
      default = null;
    };
  };

  config = {
    environment.systemPackages = lib.mkIf (cfg.sshKeyFile != null) [ pkgs.deploy-rs.deploy-rs ];

    security.sudo.extraRules = [
      {
        users = [ "deploy-rs" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    users = {
      users.deploy-rs = {
        isSystemUser = true;
        useDefaultShell = true;
        description = "NixOS deployer";
        group = "deploy-rs";
      };
      groups.deploy-rs = { };
    };

    nix.settings.trusted-users = [ "deploy-rs" ];

    programs.ssh.extraConfig = lib.mkIf (cfg.sshKeyFile != null) ''
      Host *
        Match User deploy-rs
          IdentityFile ${cfg.sshKeyFile}
          IdentitiesOnly yes
          StrictHostKeyChecking no
          UserKnownHostsFile /dev/null
    '';
  };
}
