{ config, lib, ... }:
{
  config = {
    security.doas = {
      enable = true;
      extraRules = [
        {
          users =
            builtins.attrNames config.systemUsers
            |> builtins.filter (user: config.systemUsers.${user}.root.enable);
          keepEnv = true;
          persist = true;
        }
      ];
    };
  };
}
