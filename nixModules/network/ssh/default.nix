{
  hostname,
  username,
  lib,
  std,
}: let
  keysDir = "${std.dirs.host}/keys";
  keysList =
    if (builtins.pathExists keysDir)
    then
      (builtins.attrValues (builtins.mapAttrs (fileName: fileType: (builtins.readFile "${keysDir}/${fileName}"))
          (builtins.readDir keysDir)))
    else [];
in {
  users.users."${username}".openssh.authorizedKeys.keys = keysList;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };
}
