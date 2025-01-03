{
  std,
  lib,
  systemUsers,
  config,
  ...
}:
let
  cfg = config.network.ssh;
in
{
  options.network.ssh = {
    enable = lib.mkEnableOption "ssh";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    users.users = lib.genAttrs (builtins.attrNames systemUsers) (
      user:
      let
        keysDir = "${std.dirs.host}/users/${user}/keys";
        keysList =
          if (builtins.pathExists keysDir) then
            builtins.readDir keysDir
            |> builtins.mapAttrs (fileName: fileType: (builtins.readFile "${keysDir}/${fileName}"))
            |> builtins.attrValues
          else
            [ ];
      in
      {
        openssh.authorizedKeys.keys = keysList;
      }
    );

    system.impermanence.persist.directories = [
      {
        directory = "/root/.ssh";
        user = "root";
        group = "root";
        mode = "u=rwx, g=, o=";
      }
    ];
  };
}
