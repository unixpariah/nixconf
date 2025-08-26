{
  lib,
  config,
  ...
}:
let
  cfg = config.programs.nixos-anywhere;
  inherit (lib) types;
in
{
  options.programs.nixos-anywhere = {
    enable = lib.mkOption {
      type = types.bool;
      default = true;
    };
    sshKeyFile = lib.mkOption {
      type = types.nullOr types.path;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    security.sudo.extraRules = [
      {
        users = [ "nixos-anywhere" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    users = {
      users.nixos-anywhere = {
        isSystemUser = true;
        useDefaultShell = true;
        description = "NixOS deployer";
        group = "nixos-anywhere";
        extraGroups = [ "wheel" ];
      };
      groups.nixos-anywhere = { };
    };

    nix.settings.trusted-users = [ "nixos-anywhere" ];

    programs.ssh.extraConfig = lib.mkIf (cfg.sshKeyFile != null) ''
      Match User nixos-anywhere
        IdentityFile ${cfg.sshKeyFile}
        IdentitiesOnly yes
        StrictHostKeyChecking no
        UserKnownHostsFile /dev/null
    '';
  };
}
