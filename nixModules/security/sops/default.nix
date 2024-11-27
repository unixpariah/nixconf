{
  pkgs,
  std,
  config,
  lib,
  systemUsers,
  ...
}:
let
  root = (if config.impermanence.enable then "/persist/system/root" else "/root");
in
{
  impermanence.persist.directories = [
    {
      directory = "/root/.config/sops";
      user = "root";
      group = "root";
      mode = "u=rwx, g=, o=";
    }
  ];

  sops = {
    secrets =
      {
        password.neededForUsers = true;
      }
      // lib.genAttrs (builtins.attrNames systemUsers) (user: {
        neededForUsers = true;
        sopsFile = "${std.dirs.host}/users/${user}/secrets/secrets.yaml";
      });
    defaultSopsFile = "${std.dirs.host}/secrets/secrets.yaml";
    defaultSopsFormat = "yaml";
    age = {
      sshKeyPaths = [ "${root}/.ssh/id_ed25519" ];
      keyFile = "${root}/.config/sops/age/keys.txt";
    };
  };

  environment = {
    systemPackages = with pkgs; [ sops ];
    shellAliases.opensops = "sops ${config.sops.defaultSopsFile}";
  };

  system.activationScripts = {
    sopsGenerateKey =
      let
        userScripts = (lib.attrNames systemUsers |> lib.concatMapStrings (user: "${generateAgeKey user}"));
        generateAgeKey =
          user:
          let
            escapedKeyFile = lib.escapeShellArg "/home/${user}/.config/sops/age/keys.txt";
            sshKeyPath = "/home/${user}/.ssh/id_ed25519";
          in
          ''
            mkdir -p $(dirname ${escapedKeyFile})
            ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key -i ${sshKeyPath} > ${escapedKeyFile}
            chown -R ${user} /home/${user}
            chmod 600 ${escapedKeyFile}
          '';
      in
      userScripts;

    sopsGenerateRootKey =
      let
        escapedKeyFile = lib.escapeShellArg "${root}/.config/sops/age/keys.txt";
        sshKeyPath = "${root}/.ssh/id_ed25519";
      in
      ''
        mkdir -p $(dirname ${escapedKeyFile})
        ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key -i ${sshKeyPath} > ${escapedKeyFile}
      '';
  };
}
